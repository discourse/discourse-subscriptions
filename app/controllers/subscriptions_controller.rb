# frozen_string_literal: true

module DiscoursePatrons
  class SubscriptionsController < ::ApplicationController
    include DiscoursePatrons::Stripe
    before_action :set_api_key
    requires_login

    def index
      begin
        customer = DiscoursePatrons::Customer.find_user(current_user)

        if customer.present?
          subscriptions = ::Stripe::Subscription.list(customer: customer.customer_id)
        else
          subscriptions = []
        end

        render_json_dump subscriptions

      rescue ::Stripe::InvalidRequestError => e
        return render_json_error e.message
      end
    end

    def create
      begin
        plan = ::Stripe::Plan.retrieve(params[:plan])

        @subscription = ::Stripe::Subscription.create(
          customer: params[:customer],
          items: [ { plan: params[:plan] } ]
        )

        group = plan_group(plan)

        if subscription_ok && group
          group.add(current_user)
        end

        DiscoursePatrons::Customer.create(user_id: current_user.id, customer_id: params[:customer])

        render_json_dump @subscription

      rescue ::Stripe::InvalidRequestError => e
        return render_json_error e.message
      end
    end

    private

    def plan_group(plan)
      Group.find_by_name(plan[:metadata][:group_name])
    end

    def subscription_ok
      ['active', 'trialing'].include?(@subscription[:status])
    end
  end
end
