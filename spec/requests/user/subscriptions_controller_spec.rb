# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  RSpec.describe User::SubscriptionsController do
    it 'is a subclass of ApplicationController' do
      expect(DiscourseSubscriptions::User::SubscriptionsController < ::ApplicationController).to eq(true)
    end

    context "when not authenticated" do
      it "does not get the subscriptions" do
        ::Stripe::Customer.expects(:list).never
        get "/s/user/subscriptions.json"
      end

      it "does not destroy a subscription" do
        ::Stripe::Subscription.expects(:delete).never
        patch "/s/user/subscriptions/sub_12345.json"
      end

      it "doesn't update payment method for subscription" do
        ::Stripe::Subscription.expects(:update).never
        ::Stripe::PaymentMethod.expects(:attach).never
        put "/s/user/subscriptions/sub_12345.json", params: { payment_method: "pm_abc123abc" }
      end
    end

    context "when authenticated" do
      let(:user) { Fabricate(:user, email: 'beanie@example.com') }
      let(:customer) { Fabricate(:customer, user_id: user.id, customer_id: "cus_23456", product_id: "prod_123") }

      before do
        sign_in(user)
        Fabricate(:subscription, customer_id: customer.id, external_id: "sub_1234")
      end

      describe "index" do
        let(:plans) do
          {
            data: [
              {
                id: "plan_1",
                product: { name: 'ACME Subscriptions' },
              },
              {
                id: "plan_2",
                product: { name: 'ACME Other Subscriptions' },
              }
            ]
          }
        end

        let(:customers) do
          {
            data: [{
              id: "cus_23456",
              subscriptions: {
                data: [
                  { id: "sub_1234", items: { data: [price: { id: "plan_1" }] } },
                  { id: "sub_4567", items: { data: [price: { id: "plan_2" }] } }
                ]
              },
            }]
          }
        end

        it "gets subscriptions" do
          ::Stripe::Price.expects(:list).with(
            expand: ['data.product'],
            limit: 100
          ).returns(plans)

          ::Stripe::Customer.expects(:list).with(
            email: user.email,
            expand: ['data.subscriptions']
          ).returns(customers)

          get "/s/user/subscriptions.json"

          subscription = response.parsed_body.first

          expect(subscription).to eq(
            "id" => "sub_1234",
            "items" => { "data" => [{ "price" => { "id" => "plan_1" } }] },
            "plan" => { "id" => "plan_1", "product" => { "name" => "ACME Subscriptions" } },
            "product" => { "name" => "ACME Subscriptions" }
          )
        end
      end

      describe "update" do
        it "updates the payment method for subscription" do
          ::Stripe::Subscription.expects(:update).once
          ::Stripe::PaymentMethod.expects(:attach).once
          put "/s/user/subscriptions/sub_1234.json", params: { payment_method: "pm_abc123abc" }
        end
      end
    end
  end
end
