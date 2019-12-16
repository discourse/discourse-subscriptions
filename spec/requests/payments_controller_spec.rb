# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  RSpec.describe PaymentsController do
    context "not authenticated" do
      it "does not create a payment intent" do
        ::Stripe::PaymentIntent.expects(:create).never

        post "/s/payments.json", params: {
          payment_method: 'pm_123',
          amount: 999,
          currency: 'gdp'
        }
      end
    end

    context "authenticated" do
      let(:user) { Fabricate(:user) }

      before do
        sign_in(user)
      end

      describe "create" do
        it "creates a payment intent" do
          ::Stripe::Customer.expects(:create).with(
            email: user.email
          ).returns(id: 'cus_87653')

          ::Stripe::PaymentIntent.expects(:create).with(
            payment_method_types: ['card'],
            payment_method: 'pm_123',
            amount: '999',
            currency: 'gdp',
            confirm: true,
            customer: 'cus_87653'
          )

          post "/s/payments.json", params: {
            payment_method: 'pm_123',
            amount: 999,
            currency: 'gdp'
          }
        end
      end
    end
  end
end
