# frozen_string_literal: true

module DiscourseSubscriptions
  class HooksController < ::ApplicationController
    include DiscourseSubscriptions::Group
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

      case event[:type]
      when 'customer.subscription.updated'
        customer = Customer.find_by(
          customer_id: event[:data][:object][:customer],
          product_id: event[:data][:object][:plan][:product]
        )

        if customer && subscription_completion?(event)
          user = ::User.find(customer.user_id)
          group = plan_group(event[:data][:object][:plan])
          group.add(user) if group
        end

      when 'customer.subscription.deleted'

        customer = Customer.find_by(
          customer_id: event[:data][:object][:customer],
          product_id: event[:data][:object][:plan][:product]
        )

        if customer
          customer.delete

          user = ::User.find(customer.user_id)
          group = plan_group(event[:data][:object][:plan])
          group.remove(user) if group
        end
      end

      head 200
    end

    private

    def subscription_completion?(event)
      subscription_complete?(event) && previously_incomplete?(event)
    end

    def subscription_complete?(event)
      event.dig(:data, :object, :status) == 'complete'
    end

    def previously_incomplete?(event)
      event.dig(:data, :previous_attributes, :status) == 'incomplete'
    end
  end
end
