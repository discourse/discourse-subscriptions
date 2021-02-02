# frozen_string_literal: true

module DiscourseSubscriptions
  module Admin
    class SubscriptionsController < ::Admin::AdminController
      include DiscourseSubscriptions::Stripe
      include DiscourseSubscriptions::Group
      before_action :set_api_key

      def index
        begin
          page = params[:page]
          subscription_ids = Subscription.all.pluck(:external_id)
          subscriptions = {
            has_more: false,
            data: [],
            length: 0
          }

          if subscription_ids.present? && is_stripe_configured?
            current_page = page.to_i || 0
            while subscriptions[:length] < 10
              current_set = []

              current_set = ::Stripe::Subscription.list(expand: ['data.plan.product'], limit: 10, starting_after: subscriptions[:data].last)

              if page && subscriptions[:data].empty?
                while page.to_i > current_page && current_set[:has_more] == true do
                  current_set = ::Stripe::Subscription.list(expand: ['data.plan.product'], limit: 10, starting_after: current_set[:data].last)
                  current_page += 1
                end
              end

              current_set['data'] = current_set['data'].select { |sub| subscription_ids.include?(sub[:id]) }
              # logic currently loops if current set data is empty
              unless current_set['data'] == subscriptions[:data] && current_set['data'].empty?
                subscriptions[:data] = subscriptions[:data].concat(current_set['data'])
              end
              subscriptions[:length] = subscriptions[:data].length
              subscriptions[:has_more] = current_set[:has_more]
              subscriptions[:next_page] = current_page += 1 unless current_set[:has_more] == false
              break if subscriptions[:has_more] == false
            end
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
