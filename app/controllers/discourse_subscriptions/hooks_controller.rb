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
        return render_json_error e.message
      rescue ::Stripe::SignatureVerificationError => e
        return render_json_error e.message
      end

      case event[:type]
      when 'customer.subscription.created'
      when 'customer.subscription.updated'
        customer = Customer.find_by(
          customer_id: event[:data][:object][:customer],
          product_id: event[:data][:object][:plan][:product],
        )

        return render_json_error 'customer not found' if !customer
        return head 200 if event[:data][:object][:status] != 'complete'

        user = ::User.find_by(id: customer.user_id)
        return render_json_error 'user not found' if !user

        if group = plan_group(event[:data][:object][:plan])
          group.add(user)
        end
      when 'customer.subscription.deleted'
        customer = Customer.find_by(
          customer_id: event[:data][:object][:customer],
          product_id: event[:data][:object][:plan][:product],
        )

        return render_json_error 'customer not found' if !customer

        Subscription.find_by(
          customer_id: customer.id,
          external_id: event[:data][:object][:id]
        )&.destroy

        user = ::User.find(customer.user_id)
        return render_json_error 'user not found' if !user

        if group = plan_group(event[:data][:object][:plan])
          group.remove(user)
        end

        customer.destroy
      end

      head 200
    end
  end
end
