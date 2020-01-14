# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  RSpec.describe HooksController do
    before do
      SiteSetting.discourse_subscriptions_webhook_secret = 'zascharoo'
    end

    it "contructs a webhook event" do
      payload = 'we-want-a-shrubbery'
      headers = { HTTP_STRIPE_SIGNATURE: 'stripe-webhook-signature' }

      ::Stripe::Webhook
        .expects(:construct_event)
        .with('we-want-a-shrubbery', 'stripe-webhook-signature', 'zascharoo')
        .returns(type: 'something')

      post "/s/hooks.json", params: payload, headers: headers

      expect(response.status).to eq 200
    end

    describe "canceling a subscription" do
      let(:user) { Fabricate(:user) }
      let(:group) { Fabricate(:group, name: 'subscribers-group') }
      let(:customer) { Fabricate(:customer, customer_id: 'c_575768', product_id: 'p_8654', user_id: user.id) }

      before do
        event = {
          type: 'customer.subscription.deleted',
          customer: customer.customer_id,
          plan: { product: customer.product_id, metadata: { group_name: group.name } }
        }

        ::Stripe::Webhook
          .stubs(:construct_event)
          .returns(event)

        group.add(user)
      end

      it "deletes the customer" do
        expect {
          post "/s/hooks.json"
        }.to change { DiscourseSubscriptions::Customer.count }.by(-1)

        expect(response.status).to eq 200
      end

      it "removes the user from the group" do
        expect {
          post "/s/hooks.json"
        }.to change { user.groups.count }.by(-1)

        expect(response.status).to eq 200
      end
    end
  end
end
