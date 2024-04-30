# frozen_string_literal: true

module DiscourseSubscriptions
  class HooksController < ::ApplicationController
    include DiscourseSubscriptions::Group
    include DiscourseSubscriptions::Stripe

    requires_plugin DiscourseSubscriptions::PLUGIN_NAME

    layout false

    before_action :set_api_key
    skip_before_action :check_xhr
    skip_before_action :redirect_to_login_if_required
    skip_before_action :verify_authenticity_token, only: [:create]

    def create
      begin
        payload = request.body.read
        sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
        webhook_secret = SiteSetting.discourse_subscriptions_webhook_secret

        event = ::Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
      rescue JSON::ParserError => e
        return render_json_error e.message
      rescue ::Stripe::SignatureVerificationError => e
        return render_json_error e.message
      end

      case event[:type]
      when "checkout.session.completed"
        checkout_session = event[:data][:object]
        email = checkout_session[:customer_email]

        return head 200 if checkout_session[:status] != "complete"
        return render_json_error "customer not found" if checkout_session[:customer].nil?

        customer_id = checkout_session[:customer]

        user = ::User.find_by_username_or_email(email)

        discourse_customer = Customer.find_by(user_id: user.id)

        if discourse_customer.nil?
          discourse_customer = Customer.create(user_id: user.id, customer_id: customer_id)
        end

        Subscription.create(
          customer_id: discourse_customer.id,
          external_id: checkout_session[:subscription],
        )

        line_items =
          ::Stripe::Checkout::Session.list_line_items(checkout_session[:id], { limit: 1 })
        item = line_items[:data].first
        group = plan_group(item[:price])
        group.add(user) unless group.nil?
        discourse_customer.product_id = item[:price][:product]
        discourse_customer.save!

        ::Stripe::Subscription.update(
          checkout_session[:subscription],
          { metadata: { user_id: user.id, username: user.username } },
        )
      when "customer.subscription.created"
      when "customer.subscription.updated"
        subscription = event[:data][:object]
        status = subscription[:status]
        return head 200 if !%w[complete active].include?(status)

        customer =
          Customer.find_by(
            customer_id: subscription[:customer],
            product_id: subscription[:plan][:product],
          )

        return render_json_error "customer not found" if !customer

        update_status(customer.id, subscription[:id], status)

        user = ::User.find_by(id: customer.user_id)
        return render_json_error "user not found" if !user

        if group = plan_group(subscription[:plan])
          group.add(user)
        end
      when "customer.subscription.deleted"
        subscription = event[:data][:object]
        customer =
          Customer.find_by(
            customer_id: subscription[:customer],
            product_id: subscription[:plan][:product],
          )

        return render_json_error "customer not found" if !customer

        update_status(customer.id, subscription[:id], subscription[:status])

        user = ::User.find(customer.user_id)
        return render_json_error "user not found" if !user

        if group = plan_group(subscription[:plan])
          group.remove(user)
        end
      end

      head 200
    end

    private

    def update_status(customer_id, subscription_id, status)
      discourse_subscription = Subscription.find_by(
          customer_id: customer_id,
          external_id: subscription_id,
        )
      discourse_subscription.update(status: status) if discourse_subscription
    end
  end
end
