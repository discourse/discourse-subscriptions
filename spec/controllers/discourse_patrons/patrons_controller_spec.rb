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
        expect(JSON.parse(response.body)['email']).to be_empty
      end
    end

    describe 'create' do
      let(:payment) do
        {
          id: 'xyz-1234',
          charges: { url: '/v1/charges?payment_intent=xyz-1234' },
          amount: 9000,
          receipt_email: 'hello@example.com',
          currency: 'aud'
        }
      end

      before do
        SiteSetting.stubs(:discourse_patrons_currency).returns('AUD')
        SiteSetting.stubs(:discourse_patrons_secret_key).returns('xyz-678')
        controller.stubs(:current_user).returns(Fabricate(:user))
      end

      it 'responds ok' do
        ::Stripe::PaymentIntent.expects(:create).returns(payment)
        post :create, params: { receipt_email: 'hello@example.com', amount: '20.00' }, format: :json
        expect(response).to have_http_status(200)
      end

      it 'creates a payment' do
        ::Stripe::PaymentIntent.expects(:create).returns(payment)

        expect {
          post :create, params: { receipt_email: 'hello@example.com', amount: '20.00' }, format: :json
        }.to change { Payment.count }
      end

      it 'has no user' do
        controller.stubs(:current_user).returns(nil)
        ::Stripe::PaymentIntent.expects(:create).returns(payment)
        post :create, format: :json
        expect(response).to have_http_status(200)
      end

      it 'has the correct amount' do
        ::Stripe::PaymentIntent.expects(:create).with(has_entry(:amount, 2000)).returns(payment)
        post :create, params: { amount: '20.00' }, format: :json
        expect(response).to have_http_status(200)
      end

      it 'has no amount' do
        ::Stripe::PaymentIntent.expects(:create).with(has_entry(:amount, 0)).returns(payment)
        post :create, params: {}, format: :json
        expect(response).to have_http_status(200)
      end

      it 'has curency' do
        ::Stripe::PaymentIntent.expects(:create).with(has_entry(:currency, 'AUD')).returns(payment)
        post :create, params: {}, format: :json
        expect(response).to have_http_status(200)
      end

      it 'has a receipt email' do
        ::Stripe::PaymentIntent.expects(:create).with(has_entry(:receipt_email, 'hello@example.com')).returns(payment)
        post :create, params: { receipt_email: 'hello@example.com' }, format: :json
        expect(response).to have_http_status(200)
      end

      it 'has a payment method' do
        ::Stripe::PaymentIntent.expects(:create).with(has_entry(:payment_method, 'xyz-1234')).returns(payment)
        post :create, params: { payment_method_id: 'xyz-1234' }, format: :json
        expect(response).to have_http_status(200)
      end

      it 'has a description' do
        SiteSetting.stubs(:discourse_patrons_payment_description).returns('hello-world')
        ::Stripe::PaymentIntent.expects(:create).with(has_entry(:description, 'hello-world')).returns(payment)
        post :create, params: {}, format: :json
        expect(response).to have_http_status(200)
      end
    end
  end
end
