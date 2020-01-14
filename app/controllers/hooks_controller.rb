# frozen_string_literal: true

module DiscourseSubscriptions
  class HooksController < ::ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]

    def create
      begin
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']
        webhook_secret = SiteSetting.discourse_subscriptions_webhook_secret

        event = ::Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)

      rescue JSON::ParserError => e
        # Invalid payload
        status 400
        return
      rescue Stripe::SignatureVerificationError => e
        # Invalid signature
        status 400
        return
      end

      head 200
    end
  end
end
