# frozen_string_literal: true

require 'rails_helper'

module DiscoursePatrons
  RSpec.describe PatronsController, type: :controller do
    routes { DiscoursePatrons::Engine.routes }

    describe 'index' do
      it 'responds ok' do
        get :index, format: :json
        expect(response).to have_http_status(200)
      end
    end

    describe 'create' do
      it 'responds ok' do
        post :create, params: { }, format: :json
        expect(response).to have_http_status(200)
      end
    end
  end
end
