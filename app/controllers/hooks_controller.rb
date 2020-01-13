# frozen_string_literal: true

module DiscourseSubscriptions
  class HooksController < ::ApplicationController
    def create
      begin

        # payload, sig_header, endpoint_secret
        event = ::Stripe::Webhook.construct_event(
          {},
          'stripe-webhook-signature',
          'endpoint_secret'
        )

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
