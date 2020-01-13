# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  RSpec.describe HooksController do
    it "contructs a webhook event" do
      ::Stripe::Webhook
        .expects(:construct_event)
        .with({}, 'stripe-webhook-signature', 'endpoint_secret')
        .returns(true)

      headers = {
        'HTTP_STRIPE_SIGNATURE' => 'stripe-webhook-signature'
      }

      post "/s/hooks.json"

      expect(response.status).to eq 200
    end
  end
end
