# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiscourseSubscriptions::User::PaymentsController do
  before { SiteSetting.discourse_subscriptions_enabled = true }

  it "is a subclass of ApplicationController" do
    expect(DiscourseSubscriptions::User::PaymentsController < ::ApplicationController).to eq(true)
  end

  context "when not authenticated" do
    it "does not get the payment intents" do
      ::Stripe::PaymentIntent.expects(:list).never
      get "/s/user/payments.json"
      expect(response.status).to eq(403)
    end
  end

  context "when authenticated" do
    let(:user) { Fabricate(:user, email: "zasch@example.com") }

    before do
      sign_in(user)
      Fabricate(:customer, customer_id: "c_345678", user_id: user.id)
      Fabricate(:product, external_id: "prod_8675309")
      Fabricate(:product, external_id: "prod_8675310")
    end

    it "gets payment intents" do
      created_time = Time.now
      ::Stripe::Invoice
        .expects(:list)
        .with(customer: "c_345678")
        .returns(
          data: [
            { id: "inv_900007", lines: { data: [plan: { product: "prod_8675309" }] } },
            { id: "inv_900008", lines: { data: [plan: { product: "prod_8675310" }] } },
            { id: "inv_900008", lines: { data: [plan: { product: "prod_8675310" }] } },
          ],
        )

      ::Stripe::PaymentIntent
        .expects(:list)
        .with(customer: "c_345678")
        .returns(
          data: [
            { id: "pi_900008", invoice: "inv_900008", created: created_time },
            { id: "pi_900008", invoice: "inv_900008", created: created_time },
            { id: "pi_900007", invoice: "inv_900007", created: Time.now },
            { id: "pi_007", invoice: "inv_007", created: Time.now },
          ],
        )

      get "/s/user/payments.json"

      parsed_body = response.parsed_body
      invoice = parsed_body[0]["invoice"]

      expect(invoice).to eq("inv_900007")
      expect(parsed_body.count).to eq(2)
    end
  end
end
