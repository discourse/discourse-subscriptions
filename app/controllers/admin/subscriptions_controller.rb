# frozen_string_literal: true

module DiscourseSubscriptions
  module Admin
    class SubscriptionsController < ::Admin::AdminController
      include DiscourseSubscriptions::Stripe
      include DiscourseSubscriptions::Group
      before_action :set_api_key

      def index
        begin
          subscriptions = ::Stripe::Subscription.list(expand: ['data.plan.product'])

          render_json_dump subscriptions
        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      def destroy
        begin
          subscription = ::Stripe::Subscription.delete(params[:id])

          customer = DiscourseSubscriptions::Customer.find_by(
            product_id: subscription[:plan][:product],
            customer_id: subscription[:customer]
          )

          if customer
            customer.delete

            user = ::User.find(customer.user_id)
            group = plan_group(subscription[:plan])
            group.remove(user) if group
          end

          render_json_dump subscription

        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end
    end
  end
end
