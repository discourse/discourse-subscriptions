# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe PatronsController, type: :controller do
    routes { DiscoursePatrons::Engine.routes }

    it 'responds ok for anonymous users' do
      post :create, params: {}, format: :json

      aggregate_failures do
        expect(response).to have_http_status(200)
      end
    end
  end
end
