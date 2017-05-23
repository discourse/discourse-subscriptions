require 'rails_helper'
require_relative '../../support/dd_helper'

module DiscourseDonations
  RSpec.describe DiscourseDonations::Stripe do
    before { SiteSetting.stubs(:discourse_donations_secret_key).returns('secret-key-yo') }

    let(:stripe_options) { { description: 'hi there', currency: 'AUD' } }
    let(:email) { 'ray-zintoast@example.com' }
    let(:customer) { stub(id: 1) }
    let!(:subject) { described_class.new('secret-key-yo', stripe_options) }

    it 'sets the api key' do
      expect(::Stripe.api_key).to eq 'secret-key-yo'
    end

    describe 'subscribe' do
      let(:params) { { email: email, stripeToken: 'stripe-token', plan: 'subscription-plan-1234', other: 'redundant param' } }

      it 'creates a customer and a subscription' do
        ::Stripe::Customer.expects(:create).with(
          email: email,
          source: 'stripe-token'
        ).returns(customer)
        ::Stripe::Subscription.expects(:create).with(
          customer: customer.id,
          plan: params[:plan]
        )
        subject.subscribe(email, params)
      end
    end

    describe 'charge' do
      let(:params) { { email: email, stripeToken: 'stripe-token', amount: '1234', other: 'redundant param' } }

      it 'creates a customer and charges them an amount' do
        ::Stripe::Customer.expects(:create).with(
          email: email,
          source: 'stripe-token'
        ).returns(customer)
        ::Stripe::Charge.expects(:create).with(
          customer: customer.id,
          amount: params[:amount],
          description: stripe_options[:description],
          currency: stripe_options[:currency]
        ).returns(
          {
            paid: true,
            outcome: { seller_message: 'yay!' }
          }
        )
        subject.charge(email, params)
      end
    end

    describe '.successful?' do
      let(:params) { { email: email, stripeToken: 'stripe-token', amount: '1234', other: 'redundant param' } }
      let(:charge_options) { { customer: customer.id, amount: params[:amount], description: stripe_options[:description], currency: stripe_options[:currency] } }

      before do
        ::Stripe::Customer.expects(:create).with(email: email, source: 'stripe-token').returns(customer)
      end

      it 'is successful' do
        ::Stripe::Charge.expects(:create).with(charge_options).returns({paid: true})
        subject.charge(email, params)
        expect(subject).to be_successful
      end

      it 'is not successful' do
        ::Stripe::Charge.expects(:create).with(charge_options).returns({paid: false})
        subject.charge(email, params)
        expect(subject).not_to be_successful
      end
    end
  end
end
