# frozen_string_literal: true

module DiscourseSubscriptions
  class HooksController < ::ApplicationController
    include DiscourseSubscriptions::Group
    include DiscourseSubscriptions::Stripe
    layout false
    skip_before_action :check_xhr
    skip_before_action :redirect_to_login_if_required
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
      rescue ::Stripe::SignatureVerificationError => e
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
        delete_subscription(event)
      end

      head 200
    end

    private

    def subscription_completion?(event)
      subscription_complete?(event) && previously_incomplete?(event)
    end

    def subscription_complete?(event)
      event && event[:data] && event[:data][:object] && event[:data][:object][:status] && event[:data][:object][:status] == 'complete'
    end

    def previously_incomplete?(event)
      event && event[:data] && event[:data][:previous_attributes] && event[:data][:previous_attributes][:status] && event[:data][:previous_attributes][:status] == 'incomplete'
    end

    def delete_subscription(event)
      customer = Customer.find_by(
        customer_id: event[:data][:object][:customer],
        product_id: event[:data][:object][:plan][:product]
      )

      if customer
        sub_model = Subscription.find_by(
          customer_id: customer.id,
          external_id: [:id]
        )

        sub_model.delete if sub_model

        user = ::User.find(customer.user_id)
        customer.delete
        group = plan_group(event[:data][:object][:plan])
        group.remove(user) if group
      end
    end
  end
end
