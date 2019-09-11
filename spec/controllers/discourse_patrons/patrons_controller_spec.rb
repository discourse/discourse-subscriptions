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
      before do
        SiteSetting.stubs(:discourse_patrons_currency).returns('AUD')
        SiteSetting.stubs(:discourse_patrons_secret_key).returns('xyz-678')
      end

      it 'responds ok' do
        ::Stripe::PaymentIntent.expects(:create)
        post :create, params: {}, format: :json
        expect(response).to have_http_status(200)
      end
    end
  end
end
