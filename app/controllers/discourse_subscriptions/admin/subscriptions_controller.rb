# frozen_string_literal: true

module DiscourseSubscriptions
  module Admin
    class SubscriptionsController < ::Admin::AdminController
      include DiscourseSubscriptions::Stripe
      include DiscourseSubscriptions::Group
      before_action :set_api_key

      def index
        begin
          subscription_ids = Subscription.all.pluck(:external_id)
          subscriptions = []

          if subscription_ids.present? && is_stripe_configured?
            subscriptions = ::Stripe::Subscription.list(expand: ['data.plan.product'])
            subscriptions = subscriptions.select { |sub| subscription_ids.include?(sub[:id]) }
          elsif !is_stripe_configured?
            subscriptions = nil
          end

          render_json_dump subscriptions
        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      def destroy
        params.require(:id)
        begin
          refund_subscription(params[:id]) if params[:refund]
          subscription = ::Stripe::Subscription.delete(params[:id])

          customer = Customer.find_by(
            product_id: subscription[:plan][:product],
            customer_id: subscription[:customer]
          )

          Subscription.delete_by(external_id: params[:id])

          if customer
            user = ::User.find(customer.user_id)
            customer.delete
            group = plan_group(subscription[:plan])
            group.remove(user) if group
          end

          render_json_dump subscription

        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      private

      # this will only refund the most recent subscription payment
      def refund_subscription(subscription_id)
          subscription = ::Stripe::Subscription.retrieve(subscription_id)
          invoice = ::Stripe::Invoice.retrieve(subscription[:latest_invoice]) if subscription[:latest_invoice]
          payment_intent = invoice[:payment_intent] if invoice[:payment_intent]
          refund = ::Stripe::Refund.create({
            payment_intent: payment_intent,
          })
      end
    end
  end
end
