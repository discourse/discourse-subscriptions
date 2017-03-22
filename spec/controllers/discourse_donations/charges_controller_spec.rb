require 'rails_helper'
require_relative '../../support/dd_helper'

module DiscourseDonations
  RSpec.describe ChargesController, type: :controller do
    routes { DiscourseDonations::Engine.routes }

    before do
      SiteSetting.stubs(:discourse_donations_secret_key).returns('secret-key-yo')
    end

    it 'responds ok for anonymous users' do
      post :create, { email: 'foobar@example.com' }
      expect(response).to have_http_status(200)
    end

    it 'responds ok for logged in user' do
      current_user = log_in(:coding_horror)
      post :create
      expect(response).to have_http_status(200)
    end
  end
end
