require 'rails_helper'
require_relative '../../support/dd_helper'

module DiscourseDonations
  RSpec.describe ChargesController, type: :controller do
    routes { DiscourseDonations::Engine.routes }

    before do
      SiteSetting.stubs(:discourse_donations_secret_key).returns('secret-key-yo')
      SiteSetting.stubs(:discourse_donations_description).returns('charity begins at discourse plugin')
      SiteSetting.stubs(:discourse_donations_currency).returns('AUD')
    end

    it 'responds ok for anonymous users' do
      post :create, { email: 'foobar@example.com' }
      expect(response).to have_http_status(200)
    end

    it 'responds ok when the email is empty' do
      post :create, { email: '' }
      expect(response).to have_http_status(200)
    end

    it 'responds ok for logged in user' do
      current_user = log_in(:coding_horror)
      post :create
      expect(response).to have_http_status(200)
    end

    describe 'rewards' do
      let(:group_name) { 'Zasch' }
      let(:badge_name) { 'Beanie' }
      let(:response_rewards) { JSON.parse(response.body)['rewards'] }
      let(:stripe) { ::Stripe::Charge }

      before do
        SiteSetting.stubs(:discourse_donations_reward_group_name).returns(group_name)
        SiteSetting.stubs(:discourse_donations_reward_badge_name).returns(badge_name)
        Fabricate(:group, name: group_name)
        Fabricate(:badge, name: badge_name)
      end


      describe 'new user' do
        let(:params) { { email: 'new-user@example.com' } }

        it 'has no rewards' do
          post :create
          expect(response_rewards).to be_empty
        end

        it 'enqueues add to group' do
          Jobs.expects(:enqueue_in).with(1.minute, :award_group, email: params[:email])
          post :create, params
        end

        it 'enqueues awarding a badge'
      end

      describe 'logged in user' do
        before do
          log_in :coding_horror
        end

        it 'has no rewards' do
          stripe.expects(:create).returns({ outcome: { seller_message: 'bummer' } })
          post :create
          expect(response_rewards).to be_empty
        end

        it 'awards a group' do
          post :create
          expect(response_rewards).to include({'type' => 'group', 'name' => group_name})
        end

        it 'awards a badge' do
          post :create
          expect(response_rewards).to include({'type' => 'badge', 'name' => badge_name})
        end
      end
    end
  end
end
