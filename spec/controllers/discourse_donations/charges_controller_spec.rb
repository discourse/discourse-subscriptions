require 'rails_helper'
require_relative '../../support/dd_helper'

module DiscourseDonations
  RSpec.describe ChargesController, type: :controller do
    routes { DiscourseDonations::Engine.routes }

    before do
      SiteSetting.stubs(:discourse_donations_secret_key).returns('secret-key-yo')
    end

    describe 'creating user accounts' do
      it 'creates a new user account' do
        controller.expects(:create_user).once
        post :create, { email: 'foobar@example.com' }
        expect(response).to have_http_status(200)
      end

      it 'does not create a new user account' do
        controller.expects(:create_user).never
        current_user = log_in(:coding_horror)
        post :create
        expect(response).to have_http_status(200)
      end
    end
  end
end
