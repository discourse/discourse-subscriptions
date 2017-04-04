require 'rails_helper'
require_relative '../../support/dd_helper'

module DiscourseDonations
  RSpec.describe ChargesController, type: :controller do
    routes { DiscourseDonations::Engine.routes }
    let(:body) { JSON.parse(response.body) }

    before do
      SiteSetting.stubs(:discourse_donations_secret_key).returns('secret-key-yo')
    end

    it 'responds ok for anonymous users' do
      post :create, { email: 'foobar@example.com' }
      expect(body['message']).to eq(body['outcome']['seller_message'])
      expect(response).to have_http_status(200)
    end

    it 'responds ok when the email is empty' do
      post :create, { }
      expect(body['message']).to eq('Please enter your email address')
      expect(response).to have_http_status(200)
    end

    it 'expects a username if accounts are being created' do
      post :create, { email: 'zipitydoodah@example.com', create_account: 'true' }
      expect(body['message']).to eq('Please enter a username')
      expect(response).to have_http_status(200)
    end

    it 'responds ok for logged in user' do
      current_user = log_in(:coding_horror)
      post :create
      expect(body['message']).to eq(body['outcome']['seller_message'])
      expect(response).to have_http_status(200)
    end
  end
end
