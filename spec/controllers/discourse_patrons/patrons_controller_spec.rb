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

      it 'has a current user email' do
        user = Fabricate(:user, email: 'hello@example.com')
        controller.expects(:current_user).at_least(1).returns(user)

        get :index, format: :json

        expect(JSON.parse(response.body)['email']).to eq 'hello@example.com'
      end

      it 'has no current user email' do
        get :index, format: :json
        expect(JSON.parse(response.body)['email']).to be_nil
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

      it 'has the correct amount' do
        ::Stripe::PaymentIntent.expects(:create).with(has_entry(:amount, 2000))
        post :create, params: { amount: '20.00' }, format: :json
        expect(response).to have_http_status(200)
      end

      it 'has no amount' do
        ::Stripe::PaymentIntent.expects(:create).with(has_entry(:amount, 0))
        post :create, params: {}, format: :json
        expect(response).to have_http_status(200)
      end

      it 'has curency' do
        ::Stripe::PaymentIntent.expects(:create).with(has_entry(:currency, 'AUD'))
        post :create, params: {}, format: :json
        expect(response).to have_http_status(200)
      end

      it 'has a description' do
        SiteSetting.stubs(:discourse_patrons_payment_description).returns('hello-world')
        ::Stripe::PaymentIntent.expects(:create).with(has_entry(:description, 'hello-world'))
        post :create, params: {}, format: :json
        expect(response).to have_http_status(200)
      end
    end
  end
end
