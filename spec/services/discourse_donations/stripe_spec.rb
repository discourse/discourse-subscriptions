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

    it 'creates a customer and charges them an amount' do
      options = { email: email, stripeToken: 'stripe-token', amount: '1234', other: 'redundant param' }
      ::Stripe::Customer.expects(:create).with(
        email: email,
        source: 'stripe-token'
      ).returns(customer)
      ::Stripe::Charge.expects(:create).with(
        customer: customer.id,
        amount: options[:amount],
        description: stripe_options[:description],
        currency: stripe_options[:currency]
      )
      subject.charge(email, options)
    end
  end
end
