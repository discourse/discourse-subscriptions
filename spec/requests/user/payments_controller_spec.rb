# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  RSpec.describe User::PaymentsController do
    it 'is a subclass of ApplicationController' do
      expect(DiscourseSubscriptions::User::PaymentsController < ::ApplicationController).to eq(true)
    end

    context "not authenticated" do
      it "does not get the payment intents" do
        ::Stripe::PaymentIntent.expects(:list).never
        get "/s/user/payments.json"
        expect(response.status).to eq(403)
      end
    end

    context "authenticated" do
      let(:user) { Fabricate(:user, email: 'zasch@example.com') }

      before do
        sign_in(user)
        Fabricate(:customer, customer_id: 'c_345678', user_id: user.id)
        Fabricate(:product, external_id: 'prod_8675309')
      end

      it "gets payment intents" do
        ::Stripe::Invoice.expects(:list).with(
          customer: 'c_345678'
        ).returns(
          data: [
            id: "inv_900007",
            lines: {
              data: [
                plan: {
                  product: "prod_8675309"
                }
              ]
            },
          ]
        )

        ::Stripe::PaymentIntent.expects(:list).with(
          customer: 'c_345678',
        ).returns(
          data: [
            { 
              invoice: "inv_900007",
              created: Time.now
            },
            { 
              invoice: "inv_007",
              created: Time.now
            }
          ]
        )

        get "/s/user/payments.json"

        invoice = response.parsed_body[0]["invoice"]

        expect(invoice).to eq("inv_900007")

      end

    end
  end
end
