# frozen_string_literal: true

module DiscourseSubscriptions
  class SubscriptionsController < ::ApplicationController
    include DiscourseSubscriptions::Stripe
    include DiscourseSubscriptions::Group
    before_action :set_api_key
    requires_login

    def index
      begin
        products = ::Stripe::Product.list(active: true)

        subscriptions = products[:data].map do |p|
          {
            id: p[:id],
            description: p.dig(:metadata, :description)
          }
        end

        render_json_dump subscriptions

      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
    end

    def create
      begin
        plan = ::Stripe::Plan.retrieve(params[:plan])

        @subscription = ::Stripe::Subscription.create(
          customer: params[:customer],
          items: [ { plan: params[:plan] } ],
          metadata: metadata_user,
        )

        group = plan_group(plan)

        if subscription_ok && group
          group.add(current_user)
        end

        customer = Customer.create(
          user_id: current_user.id,
          customer_id: params[:customer],
          product_id: plan[:product]
        )

        Subscription.create(
          customer_id: customer.id,
          external_id: @subscription[:id]
        )

        render_json_dump @subscription

      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
    end

    private

    def metadata_user
      { user_id: current_user.id, username: current_user.username_lower }
    end

    def subscription_ok
      ['active', 'trialing'].include?(@subscription[:status])
    end
  end
end
