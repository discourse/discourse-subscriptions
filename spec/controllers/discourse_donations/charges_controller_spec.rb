require 'rails_helper'

module DiscourseDonations
  RSpec.describe ChargesController, type: :controller do
    routes { DiscourseDonations::Engine.routes }
  #
    it 'responds with ok' do
      skip 'need to get fixtures'
      post :create
      expect(response).to have_http_status(200)
    end
  end
end
