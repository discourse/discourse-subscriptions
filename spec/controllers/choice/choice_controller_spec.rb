require 'rails_helper'

module Choice
  RSpec.describe ChoiceController, type: :controller do
    routes { Choice::Engine.routes }

    it 'responds with ok' do
      post :create
      expect(response).to have_http_status(200)
    end
  end
end
