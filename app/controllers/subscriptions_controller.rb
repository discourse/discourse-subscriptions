# frozen_string_literal: true

module DiscoursePatrons
  class SubscriptionsController < ::ApplicationController
    include DiscoursePatrons::Stripe
    before_action :set_api_key
    requires_login

    def index
      begin
        customers = ::Stripe::Customer.list(
          email: current_user.email,
          expand: ['data.subscriptions']
        )


        subscriptions = customers[:data].map do |customer|
          customer[:subscriptions][:data]
        end.flatten(1)

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

        unless DiscoursePatrons::Customer.exists?(user_id: current_user.id)
          DiscoursePatrons::Customer.create(user_id: current_user.id, customer_id: params[:customer])
        end

        render_json_dump @subscription

      rescue ::Stripe::InvalidRequestError => e
        return render_json_error e.message
      end
    end

    def destroy
      begin
        subscription = ::Stripe::Subscription.delete(params[:id])

        render_json_dump subscription

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
