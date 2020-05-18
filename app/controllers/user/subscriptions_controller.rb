# frozen_string_literal: true

module DiscourseSubscriptions
  module User
    class SubscriptionsController < ::ApplicationController
      include DiscourseSubscriptions::Stripe
      include DiscourseSubscriptions::Group
      before_action :set_api_key
      requires_login

      def index
        begin
          subscription_ids = Customer.find_by(user_id: current_user.id).subscriptions.pluck(:external_id)

          plans = ::Stripe::Plan.list(
            expand: ['data.product']
          )

          customers = ::Stripe::Customer.list(
            email: current_user.email,
            expand: ['data.subscriptions']
          )

          subscriptions = customers[:data].map do |customer|
            customer[:subscriptions][:data]
          end.flatten(1)

          subscriptions.map! do |subscription|
            plan = plans[:data].find { |p| p[:id] == subscription[:plan][:id] }
            subscription.to_h.merge(product: plan[:product].to_h.slice(:id, :name))
          end

          subscriptions = subscriptions.select { |sub| subscription_ids.include?(sub[:id]) }

          render_json_dump subscriptions

        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      def destroy
        begin
          subscription = ::Stripe::Subscription.retrieve(params[:id])

          customer = Customer.find_by(
            user_id: current_user.id,
            customer_id: subscription[:customer],
            product_id: subscription[:plan][:product]
          )

          if customer.present?
            sub_model = Subscription.find_by(
              customer_id: customer.id,
              external_id: params[:id]
            )

            deleted = ::Stripe::Subscription.delete(params[:id])
            customer.delete

            sub_model.delete if sub_model

            group = plan_group(subscription[:plan])
            group.remove(current_user) if group

            render_json_dump deleted
          else
            render_json_error I18n.t('discourse_subscriptions.customer_not_found')
          end

        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end
    end
  end
end
