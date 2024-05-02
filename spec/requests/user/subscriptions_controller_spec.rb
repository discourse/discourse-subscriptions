# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiscourseSubscriptions::User::SubscriptionsController do
  before { SiteSetting.discourse_subscriptions_enabled = true }

  it "is a subclass of ApplicationController" do
    expect(DiscourseSubscriptions::User::SubscriptionsController < ::ApplicationController).to eq(
      true,
    )
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
    let(:user) { Fabricate(:user, email: "beanie@example.com") }
    let(:customer) do
      Fabricate(:customer, user_id: user.id, customer_id: "cus_23456", product_id: "prod_123")
    end

    before do
      sign_in(user)
      Fabricate(:subscription, customer_id: customer.id, external_id: "sub_10z")
    end

    describe "index" do
      plans_json =
        File.read(
          Rails.root.join(
            "plugins",
            "discourse-subscriptions",
            "spec",
            "fixtures",
            "json",
            "stripe-price-list.json",
          ),
        )

      it "gets subscriptions" do
        ::Stripe::Price.stubs(:list).returns(JSON.parse(plans_json, symbolize_names: true))

        subscriptions_json =
          File.read(
            Rails.root.join(
              "plugins",
              "discourse-subscriptions",
              "spec",
              "fixtures",
              "json",
              "stripe-subscription-list.json",
            ),
          )

        ::Stripe::Subscription.stubs(:list).returns(
          JSON.parse(subscriptions_json, symbolize_names: true),
        )

        get "/s/user/subscriptions.json"

        subscription = JSON.parse(response.body, symbolize_names: true).first

        expect(subscription[:id]).to eq("sub_10z")
        expect(subscription[:items][:data][0][:plan][:id]).to eq("price_1OrmlvEYXaQnncShNahrpKvA")
        expect(subscription[:product][:name]).to eq("Exclusive Access")
      end
    end

    describe "update" do
      it "updates the payment method for subscription" do
        ::Stripe::Subscription.expects(:update).once
        ::Stripe::PaymentMethod.expects(:attach).once
        put "/s/user/subscriptions/sub_10z.json", params: { payment_method: "pm_abc123abc" }
      end
    end
  end
end
