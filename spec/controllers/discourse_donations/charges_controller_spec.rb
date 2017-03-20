require 'rails_helper'
require_relative '../../support/dd_helper'

module DiscourseDonations
  RSpec.describe ChargesController, type: :controller do
    routes { DiscourseDonations::Engine.routes }

    before do
      SiteSetting.stubs(:discourse_donations_secret_key).returns('secret-key-yo')
      current_user = log_in(:coding_horror)
    end

    it 'responds with ok' do
      post :create
      expect(response).to have_http_status(200)
    end
  end
end
