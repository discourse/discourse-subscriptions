require 'rails_helper'

module DiscoursePayments
  RSpec.describe ChargesController, type: :controller do
    routes { DiscoursePayments::Engine.routes }
  #
    it 'responds with ok' do
      skip 'need to get fixtures'
      post :create
      expect(response).to have_http_status(200)
    end
  end
end
