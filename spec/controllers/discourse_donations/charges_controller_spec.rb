require 'rails_helper'

shared_examples 'failure response' do |message_key|
  let(:body) { JSON.parse(response.body) }

  it 'has status 200' do expect(response).to have_http_status(200) end
  it 'has an error message' do expect(body['messages']).to include(I18n.t(message_key)) end
  it 'is not successful' do expect(body['success']).to eq false end
  it 'does not create a payment' do DiscourseDonations::Stripe.expects(:new).never end
  it 'does not create rewards' do DiscourseDonations::Rewards.expects(:new).never end
  it 'does not queue up any jobs' do ::Jobs.expects(:enqueue).never end
end

module DiscourseDonations
  RSpec.describe ChargesController, type: :controller do
    routes { DiscourseDonations::Engine.routes }
    let(:body) { JSON.parse(response.body) }
    fab!(:user) { Fabricate(:user, name: 'Lynette') }

    before do
      SiteSetting.stubs(:disable_discourse_narrative_bot_welcome_post).returns(true)
      SiteSetting.stubs(:discourse_donations_secret_key).returns('secret-key-yo')
      SiteSetting.stubs(:discourse_donations_description).returns('charity begins at discourse plugin')
      SiteSetting.stubs(:discourse_donations_currency).returns('AUD')
    end

    # Workaround for rails-5 issue. See https://github.com/thoughtbot/shoulda-matchers/issues/1018#issuecomment-315876453
    let(:allowed_params) { { create_account: 'true', email: 'email@example.com', password: 'secret', username: 'mr-pink', name: 'kirsten', amount: 100, stripeToken: 'rrurrrurrrrr' } }

    it 'whitelists the params' do
      should permit(:name, :username, :email, :password, :create_account).
        for(:create, params: { params: allowed_params })
    end

    it 'responds ok for anonymous users' do
      controller.expects(:current_user).at_least(1).returns(user)

      customer = Fabricate(:stripe_customer).to_json

      stub_request(:get, /v1\/customers/).to_return(status: 200, body: customer)

      plans = Fabricate(:stripe_plans).to_json

      stub_request(:get, "https://api.stripe.com/v1/plans").to_return(status: 200, body: plans)
      stub_request(:post, "https://api.stripe.com/v1/plans").to_return(status: 200, body: plans)

      products = Fabricate(:stripe_products).to_json

      stub_request(:get, "https://api.stripe.com/v1/products?type=service").to_return(status: 200, body: products)
      stub_request(:post, "https://api.stripe.com/v1/products").to_return(status: 200, body: products)
      stub_request(:post, "https://api.stripe.com/v1/customers").to_return(status: 200, body: customer)

      subscription = Fabricate(:stripe_subscription).to_json

      stub_request(:post, "https://api.stripe.com/v1/subscriptions").to_return(status: 200, body: subscription)

      invoices = Fabricate(:stripe_invoices).to_json

      stub_request(:get, "https://api.stripe.com/v1/invoices?customer=cus_FhHJDzf0OxYtb8&subscription=sub_8epEF0PuRhmltU")
        .to_return(status: 200, body: invoices)

      post :create, params: { email: 'foobar@example.com' }, format: :json

      aggregate_failures do
        expect(response).to have_http_status(200)
        expect(body['messages'][0]).to end_with(I18n.t('donations.payment.success'))
      end
    end

    it 'does not expect a username or email if accounts are not being created' do
      current_user = log_in(:coding_horror)
      post :create, params: { create_account: 'false' }, format: :json
      expect(body['messages'][0]).to end_with(I18n.t('donations.payment.success'))
      expect(response).to have_http_status(200)
    end

    describe 'create accounts' do
      describe 'create acccount disabled' do
        let(:params) { { amount: 100, stripeToken: 'rrurrrurrrrr-rrruurrrr' } }

        before do
          SiteSetting.stubs(:discourse_donations_enable_create_accounts).returns(false)
          ::Jobs.expects(:enqueue).never
        end

        it 'does not create user accounts' do
          post :create, params: params, format: :json
        end

        it 'does not create user accounts if the user is logged in' do
          log_in :coding_horror
          post :create, params: params, format: :json
        end

        it 'does not create user accounts when settings are disabled and params are not' do
          log_in :coding_horror
          post :create, params: params.merge(create_account: true, email: 'email@example.com', password: 'secret', username: 'mr-brown', name: 'hacker-guy')
        end
      end

      describe 'creating an account enabled' do
        let(:params) { { create_account: 'true', email: 'email@example.com', password: 'secret', username: 'mr-pink', amount: 100, stripeToken: 'rrurrrurrrrr-rrruurrrr' } }

        before do
          SiteSetting.stubs(:discourse_donations_enable_create_accounts).returns(true)
          Jobs.expects(:enqueue).with(:donation_user, anything)
        end

        it 'enqueues the user account create' do
          post :create, params: params
        end
      end
    end

    describe 'new user' do
      let(:params) { { create_account: 'true', email: 'email@example.com', password: 'secret', username: 'mr-pink', amount: 100, stripeToken: 'rrurrrurrrrr-rrruurrrr' } }

      before { SiteSetting.stubs(:discourse_donations_enable_create_accounts).returns(true) }

      describe 'requires an email' do
        before { post :create, params: params.merge(email: '') }
        include_examples 'failure response', 'login.missing_user_field'
      end

      describe 'requires a username' do
        before { post :create, params: params.merge(username: '') }
        include_examples 'failure response', 'login.missing_user_field'
      end

      describe 'reserved usernames' do
        before do
          User.expects(:reserved_username?).returns(true)
          post :create, params: params
        end

        include_examples 'failure response', 'login.reserved_username'
      end

      describe 'minimum password length' do
        before do
          User.expects(:max_password_length).returns(params[:password].length - 1)
          post :create, params: params
        end

        include_examples 'failure response', 'login.password_too_long'
      end
    end

    describe 'rewards' do
      let(:body) { JSON.parse(response.body) }
      let(:stripe) { ::Stripe::Charge }

      shared_examples 'no rewards' do
        it 'has no rewards' do
          post :create, params: params
          expect(body['rewards']).to be_empty
        end
      end

      describe 'new user' do
        let(:params) { { create_account: 'true', email: 'dood@example.com', password: 'secretsecret', name: 'dood', username: 'mr-dood' } }

        before { SiteSetting.stubs(:discourse_donations_enable_create_accounts).returns(true) }

        include_examples 'no rewards' do
          before do
            stripe.stubs(:create).returns({ 'paid' => false })
          end
        end

        include_examples 'no rewards' do
          before do
            stripe.stubs(:create).returns({ 'paid' => true })
            SiteSetting.stubs(:discourse_donations_reward_group_name).returns(nil)
            SiteSetting.stubs(:discourse_donations_reward_badge_name).returns(nil)
          end
        end
      end

      describe 'logged in user' do
        before do
          log_in :coding_horror
        end

        include_examples 'no rewards' do
          let(:params) { {} }

          before do
            stripe.stubs(:create).returns({ 'paid' => true })
            SiteSetting.stubs(:discourse_donations_reward_group_name).returns(nil)
            SiteSetting.stubs(:discourse_donations_reward_badge_name).returns(nil)
          end
        end

        describe 'rewards' do
          let(:group_name) { 'Zasch' }
          let(:badge_name) { 'Beanie' }
          let!(:grp) { Fabricate(:group, name: group_name) }
          let!(:badge) { Fabricate(:badge, name: badge_name) }

          before do
            SiteSetting.stubs(:discourse_donations_reward_group_name).returns(group_name)
            SiteSetting.stubs(:discourse_donations_reward_badge_name).returns(badge_name)
            stripe.stubs(:create).returns({ 'paid' => true })
          end

          it 'awards a group' do
            post :create
            expect(body['rewards']).to include({ 'type' => 'group', 'name' => group_name })
          end

          it 'awards a badge' do
            post :create
            expect(body['rewards']).to include({ 'type' => 'badge', 'name' => badge_name })
          end
        end
      end
    end
  end
end
