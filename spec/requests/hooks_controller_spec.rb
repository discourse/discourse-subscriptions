# frozen_string_literal: true

require 'rails_helper'

module DiscourseSubscriptions
  RSpec.describe HooksController do
    before do
      SiteSetting.discourse_subscriptions_webhook_secret = 'zascharoo'
    end

    it "contructs a webhook event" do
      payload = 'we-want-a-shrubbery'
      headers = { 'HTTP_STRIPE_SIGNATURE' => 'stripe-webhook-signature' }

      ::Stripe::Webhook
        .expects(:construct_event)
        .with('we-want-a-shrubbery', 'stripe-webhook-signature', 'zascharoo')

      post "/s/hooks.json", params: payload, headers: headers

      expect(response.status).to eq 200
    end
  end
end
