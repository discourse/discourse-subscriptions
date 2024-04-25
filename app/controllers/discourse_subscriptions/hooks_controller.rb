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
        email = checkout_session[:customer_details][:email]
        customer_id = checkout_session[:id]
        customer_id = checkout_session[:customer] unless checkout_session[:customer].nil?

        user = ::User.find_by_username_or_email(email)

        discourse_customer = Customer.find_by(user_id: user.id)
        if discourse_customer.nil?
          discourse_customer = Customer.create(user_id: user.id, customer_id: customer_id)
        else
          discourse_customer =
            Customer.update(user_id: user.id, customer_id: checkout_session[:customer])
        end

        Subscription.create(
          customer_id: discourse_customer.id,
          external_id: checkout_session[:subscription],
        )

        line_items =
          ::Stripe::Checkout::Session.list_line_items(checkout_session[:id], { limit: 100 })
        line_items.each do |item|
          group = plan_group(item[:price])
          group.add(user) unless group.nil?
          discourse_customer.product_id = item[:price][:product]
          discourse_customer.save!
        end

        ::Stripe::Subscription.update(checkout_session[:subscription], {
          metadata: {
            user_id: user.id,
            username: user.username
          }
        })
      when "customer.subscription.created"
      when "customer.subscription.updated"
        customer =
          Customer.find_by(
            customer_id: event[:data][:object][:customer],
            product_id: event[:data][:object][:plan][:product],
          )

        return render_json_error "customer not found" if !customer
        return head 200 if event[:data][:object][:status] != "complete"

        user = ::User.find_by(id: customer.user_id)
        return render_json_error "user not found" if !user

        if group = plan_group(event[:data][:object][:plan])
          group.add(user)
        end
      when "customer.subscription.deleted"
        customer =
          Customer.find_by(
            customer_id: event[:data][:object][:customer],
            product_id: event[:data][:object][:plan][:product],
          )

        return render_json_error "customer not found" if !customer

        Subscription.find_by(
          customer_id: customer.id,
          external_id: event[:data][:object][:id],
        )&.destroy!

        user = ::User.find(customer.user_id)
        return render_json_error "user not found" if !user

        if group = plan_group(event[:data][:object][:plan])
          group.remove(user)
        end

        customer.destroy!
      end

      head 200
    end
  end
end
