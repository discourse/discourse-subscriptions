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
        render_json_error e.message
        return
      rescue Stripe::SignatureVerificationError => e
        render_json_error e.message
        return
      end

      head 200
    end
  end
end
