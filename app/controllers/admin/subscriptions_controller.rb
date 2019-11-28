# frozen_string_literal: true

module DiscoursePatrons
  module Admin
    class SubscriptionsController < ::Admin::AdminController
      include DiscoursePatrons::Stripe

      before_action :set_api_key

      def index
        begin
          subscriptions = ::Stripe::Subscription.list(expand: ['data.plan.product'])

          render_json_dump subscriptions
        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end

      def destroy
        begin
          subscription = ::Stripe::Subscription.delete(params[:id])

          customer = DiscoursePatrons::Customer.find_by(
            product_id: subscription[:plan][:product][:id],
            customer_id: subscription[:customer]
          )

          customer.delete if customer

          render_json_dump subscription

        rescue ::Stripe::InvalidRequestError => e
          return render_json_error e.message
        end
      end

    end
  end
end
