require 'rails_helper'
require_relative '../../support/dd_helper'

shared_examples 'failure response' do |message_key|
  let(:body) { JSON.parse(response.body) }

  it 'has status 200' do expect(response).to have_http_status(200) end
  it 'has an error message' do expect(body['messages']).to include(I18n.t(message_key)) end
  it 'is not successful' do expect(body['success']).to eq false end
  it 'does not create a payment' do DiscourseDonations::Stripe.expects(:new).never end
  it 'does not create rewards' do DiscourseDonations::Rewards.expects(:new).never end
end

module DiscourseDonations
  RSpec.describe ChargesController, type: :controller do
    routes { DiscourseDonations::Engine.routes }
    let(:body) { JSON.parse(response.body) }

    before do
      SiteSetting.stubs(:discourse_donations_secret_key).returns('secret-key-yo')
      SiteSetting.stubs(:discourse_donations_description).returns('charity begins at discourse plugin')
      SiteSetting.stubs(:discourse_donations_currency).returns('AUD')
    end

    it 'responds ok for anonymous users' do
      post :create, { email: 'foobar@example.com' }
      expect(body['messages']).to include('Payment complete.')
      expect(response).to have_http_status(200)
    end

    it 'does not expect a username or email if accounts are not being created' do
      current_user = log_in(:coding_horror)
      post :create, { create_account: 'false' }
      expect(body['messages']).to include('Payment complete.')
      expect(response).to have_http_status(200)
    end

    describe 'new user' do
      let(:params) { { create_account: 'true', email: 'email@example.com', password: 'secret', username: 'mr-pink' } }

      describe 'requires an email' do
        before { post :create, params.merge(email: '') }
        include_examples 'failure response', 'login.missing_user_field'
      end

      describe 'requires a username' do
        before { post :create, params.merge(username: '') }
        include_examples 'failure response', 'login.missing_user_field'
      end

      describe 'reserved usernames' do
        before do
          User.expects(:reserved_username?).returns(true)
          post :create, params
        end

        include_examples 'failure response', 'login.reserved_username'
      end

      describe 'minimum password length' do
        before do
          User.expects(:max_password_length).returns(params[:password].length - 1)
          post :create, params
        end

        include_examples 'failure response', 'login.password_too_long'
      end
    end

    describe 'rewards' do
      let(:group_name) { 'Zasch' }
      let(:badge_name) { 'Beanie' }
      let(:body) { JSON.parse(response.body) }
      let(:stripe) { ::Stripe::Charge }
      let!(:grp) { Fabricate(:group, name: group_name) }
      let!(:badge) { Fabricate(:badge, name: badge_name) }

      before do
        SiteSetting.stubs(:discourse_donations_reward_group_name).returns(group_name)
        SiteSetting.stubs(:discourse_donations_reward_badge_name).returns(badge_name)
      end

      describe 'new user' do
        let(:params) { { email: 'new-user@example.com' } }

        it 'has no rewards' do
          post :create
          expect(body['rewards']).to be_empty
        end

        it 'stores the email in group:add and badge:grant and adds them' do
          PluginStore.expects(:get).with('discourse-donations', 'group:add').returns([])
          PluginStore.expects(:set).with('discourse-donations', 'group:add', [params[:email]])
          PluginStore.expects(:get).with('discourse-donations', 'badge:grant').returns([])
          PluginStore.expects(:set).with('discourse-donations', 'badge:grant', [params[:email]])
          post :create, params
        end
      end

      describe 'logged in user' do
        before do
          log_in :coding_horror
        end

        it 'has no rewards' do
          stripe.expects(:create).returns({ 'outcome' => { 'seller_message' => 'bummer' } })
          post :create
          expect(body['rewards']).to be_empty
        end

        it 'awards a group' do
          post :create
          expect(body['rewards']).to include({'type' => 'group', 'name' => group_name})
        end

        it 'awards a badge' do
          post :create
          expect(body['rewards']).to include({'type' => 'badge', 'name' => badge_name})
        end
      end
    end
  end
end
