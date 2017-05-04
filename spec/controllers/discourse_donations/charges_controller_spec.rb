require 'rails_helper'
require_relative '../../support/dd_helper'

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

    it 'expects a username if accounts are being created' do
      post :create, { email: 'zipitydoodah@example.com', create_account: 'true' }
      expect(body['messages']).to include('Please enter a username')
      expect(response).to have_http_status(200)
    end

    it 'does not expect a username or email if accounts are not being created' do
      current_user = log_in(:coding_horror)
      post :create, { create_account: 'false' }
      expect(body['messages']).to include('Payment complete.')
      expect(response).to have_http_status(200)
    end

    describe 'new user' do
      it 'has a message when the email is empty' do
        post :create, { create_account: 'true', email: '' }
        expect(body['messages']).to include('Please enter your email address')
      end

      it 'has a message when the email is empty' do
        post :create, { create_account: 'true' }
        expect(body['messages']).to include('Please enter your email address')
      end

      it 'has a message when the username is reserved' do
        User.expects(:reserved_username?).returns(true)
        post :create, { username: 'admin', create_account: 'true', email: 'something@example.com' }
        expect(body['messages']).to include(I18n.t('login.reserved_username'))
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
