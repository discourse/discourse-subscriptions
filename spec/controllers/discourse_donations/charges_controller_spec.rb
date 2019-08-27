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

      products = {
        "object": "list",
        "url": "/v1/products",
        "has_more": false,
        "data": [
          {
            "id": "prod_FhGJ7clA2xMxGI",
            "object": "product",
            "active": true,
            "attributes": [],
            "caption": "null",
            "created": 1566862775,
            "deactivate_on": [],
            "description": "null",
            "images": [],
            "livemode": false,
            "metadata": {},
            "name": "Sapphire Personal",
            "package_dimensions": "null",
            "shippable": "null",
            "statement_descriptor": "null",
            "type": "service",
            "unit_label": "null",
            "updated": 1566862775,
            "url": "null"
          },
        ]
      }

      stub_request(:get, "https://api.stripe.com/v1/products?type=service").to_return(status: 200, body: products.to_json)
      stub_request(:post, "https://api.stripe.com/v1/products").to_return(status: 200, body: products.to_json)
      stub_request(:post, "https://api.stripe.com/v1/customers").to_return(status: 200, body: customer)

      subscription = {
        "id": "sub_8epEF0PuRhmltU",
        "object": "subscription",
        "application_fee_percent": "null",
        "billing": "charge_automatically",
        "billing_cycle_anchor": 1466202990,
        "billing_thresholds": "null",
        "cancel_at": "null",
        "cancel_at_period_end": false,
        "canceled_at": 1517528245,
        "collection_method": "charge_automatically",
        "created": 1466202990,
        "current_period_end": 1518906990,
        "current_period_start": 1516228590,
        "customer": "cus_FhHJDzf0OxYtb8",
        "days_until_due": "null",
        "default_payment_method": "null",
        "default_source": "null",
        "default_tax_rates": [],
        "discount": "null",
        "ended_at": 1517528245,
        "items": {
          "object": "list",
          "data": [
            {
              "id": "si_18NVZi2eZvKYlo2CUtBNGL9x",
              "object": "subscription_item",
              "billing_thresholds": "null",
              "created": 1466202990,
              "metadata": {},
              "plan": {
                "id": "ivory-freelance-040",
                "object": "plan",
                "active": true,
                "aggregate_usage": "null",
                "amount": 999,
                "amount_decimal": "999",
                "billing_scheme": "per_unit",
                "created": 1466202980,
                "currency": "usd",
                "interval": "month",
                "interval_count": 1,
                "livemode": false,
                "metadata": {},
                "nickname": "null",
                "product": "prod_BUthVRQ7KdFfa7",
                "tiers": "null",
                "tiers_mode": "null",
                "transform_usage": "null",
                "trial_period_days": "null",
                "usage_type": "licensed"
              },
              "quantity": 1,
              "subscription": "sub_8epEF0PuRhmltU",
              "tax_rates": []
            }
          ],
          "has_more": false,
          "total_count": 1,
          "url": "/v1/subscription_items?subscription=sub_8epEF0PuRhmltU"
        },
        "latest_invoice": "null",
        "livemode": false,
        "metadata": {},
        "pending_setup_intent": "null",
        "plan": {
          "id": "ivory-freelance-040",
          "object": "plan",
          "active": true,
          "aggregate_usage": "null",
          "amount": 999,
          "amount_decimal": "999",
          "billing_scheme": "per_unit",
          "created": 1466202980,
          "currency": "usd",
          "interval": "month",
          "interval_count": 1,
          "livemode": false,
          "metadata": {},
          "nickname": "null",
          "product": "prod_BUthVRQ7KdFfa7",
          "tiers": "null",
          "tiers_mode": "null",
          "transform_usage": "null",
          "trial_period_days": "null",
          "usage_type": "licensed"
        },
        "quantity": 1,
        "schedule": "null",
        "start": 1466202990,
        "start_date": 1466202990,
        "status": "active",
        "tax_percent": "null",
        "trial_end": "null",
        "trial_start": "null"
      }

      stub_request(:post, "https://api.stripe.com/v1/subscriptions").to_return(status: 200, body: subscription.to_json)

      invoices = {
        "object": "list",
        "url": "/v1/invoices",
        "has_more": false,
        "data": [
          {
            "id": "in_1Cc9wc2eZvKYlo2ClBzJbDQz",
            "object": "invoice",
            "account_country": "US",
            "account_name": "Stripe.com",
            "amount_due": 20,
            "amount_paid": 0,
            "amount_remaining": 20,
            "application_fee_amount": "null",
            "attempt_count": 0,
            "attempted": false,
            "auto_advance": false,
            "billing": "send_invoice",
            "billing_reason": "subscription_update",
            "charge": "null",
            "collection_method": "send_invoice",
            "created": 1528800106,
            "currency": "usd",
            "custom_fields": "null",
            "customer": "cus_FhHJDzf0OxYtb8",
            "customer_address": "null",
            "customer_email": "ziad+123@elysian.team",
            "customer_name": "null",
            "customer_phone": "null",
            "customer_shipping": "null",
            "customer_tax_exempt": "none",
            "customer_tax_ids": [],
            "default_payment_method": "null",
            "default_source": "null",
            "default_tax_rates": [],
            "description": "null",
            "discount": "null",
            "due_date": 1529059306,
            "ending_balance": "null",
            "footer": "null",
            "hosted_invoice_url": "null",
            "invoice_pdf": "null",
            "lines": {
              "data": [
                {
                  "id": "sli_42e8bf79bec714",
                  "object": "line_item",
                  "amount": 999,
                  "currency": "usd",
                  "description": "1 × Ivory Freelance (at $9.99 / month)",
                  "discountable": true,
                  "livemode": false,
                  "metadata": {},
                  "period": {
                    "end": 1521326190,
                    "start": 1518906990
                  },
                  "plan": {
                    "id": "ivory-freelance-040",
                    "object": "plan",
                    "active": true,
                    "aggregate_usage": "null",
                    "amount": 999,
                    "amount_decimal": "999",
                    "billing_scheme": "per_unit",
                    "created": 1466202980,
                    "currency": "usd",
                    "interval": "month",
                    "interval_count": 1,
                    "livemode": false,
                    "metadata": {},
                    "nickname": "null",
                    "product": "prod_BUthVRQ7KdFfa7",
                    "tiers": "null",
                    "tiers_mode": "null",
                    "transform_usage": "null",
                    "trial_period_days": "null",
                    "usage_type": "licensed"
                  },
                  "proration": false,
                  "quantity": 1,
                  "subscription": "sub_8epEF0PuRhmltU",
                  "subscription_item": "si_18NVZi2eZvKYlo2CUtBNGL9x",
                  "tax_amounts": [],
                  "tax_rates": [],
                  "type": "subscription"
                }
              ],
              "has_more": false,
              "object": "list",
              "url": "/v1/invoices/in_1Cc9wc2eZvKYlo2ClBzJbDQz/lines"
            },
            "livemode": false,
            "metadata": {},
            "next_payment_attempt": "null",
            "number": "8B36FE9-0005",
            "paid": false,
            "payment_intent": "null",
            "period_end": 1528800106,
            "period_start": 1528800106,
            "post_payment_credit_notes_amount": 0,
            "pre_payment_credit_notes_amount": 0,
            "receipt_number": "null",
            "starting_balance": 10,
            "statement_descriptor": "null",
            "status": "draft",
            "status_transitions": {
              "finalized_at": "null",
              "marked_uncollectible_at": "null",
              "paid_at": "null",
              "voided_at": "null"
            },
            "subscription": "sub_D2ECXpuEnnXkWU",
            "subtotal": 10,
            "tax": "null",
            "tax_percent": "null",
            "total": 10,
            "total_tax_amounts": [],
            "webhooks_delivered_at": 1528800106
          },
        ]
      }

      stub_request(:get, "https://api.stripe.com/v1/invoices?customer=cus_FhHJDzf0OxYtb8&subscription=sub_8epEF0PuRhmltU")
        .to_return(status: 200, body: invoices.to_json)

      post :create, params: { email: 'foobar@example.com' }, format: :json
      expect(body['messages'][0]).to end_with(I18n.t('donations.payment.success'))
      expect(response).to have_http_status(200)
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
