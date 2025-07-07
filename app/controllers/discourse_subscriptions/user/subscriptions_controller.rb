# frozen_string_literal: true

module DiscourseSubscriptions
  module User
    class SubscriptionsController < ::ApplicationController
      include DiscourseSubscriptions::Stripe
      include DiscourseSubscriptions::Group

      requires_plugin DiscourseSubscriptions::PLUGIN_NAME

      before_action :set_api_key
      requires_login

      # app/controllers/discourse_subscriptions/user/subscriptions_controller.rb

      def index
        begin
          # --- START OF SECURITY FIX ---
          # This query now explicitly joins through the `customer` to the `user`
          # and filters on the `users` table. This is a more robust and secure
          # way to ensure we only fetch subscriptions for the current user.
          local_subscriptions = ::DiscourseSubscriptions::Subscription
                                  .joins(customer: :user)
                                  .where(users: { id: current_user.id })
                                  .order(created_at: :desc)
          # --- END OF SECURITY FIX ---

          return render json: [] if local_subscriptions.empty?

          all_plans = is_stripe_configured? ? ::Stripe::Price.list(limit: 100, active: true, expand: ['data.product']) : []

          processed_subscriptions = local_subscriptions.map do |sub|
            plan = all_plans.find { |p| p.id == sub.plan_id } if sub.plan_id

            if plan.nil? && (sub.provider == 'Stripe' || sub.provider.nil?) && is_stripe_configured?
              begin
                stripe_sub = ::Stripe::Subscription.retrieve({ id: sub.external_id, expand: ['items.data.price.product'] })
                plan = stripe_sub&.items&.data&.first&.price
              rescue ::Stripe::InvalidRequestError
                next
              end
            end

            next unless plan

            renews_at_timestamp = (sub.provider == 'Stripe' && sub.status == 'active' && plan.recurring) ? ::Stripe::Subscription.retrieve(sub.external_id)&.current_period_end : nil

            {
              id: sub.external_id,
              provider: (sub.provider || 'Stripe').capitalize,
              status: sub.status,
              plan_nickname: plan.nickname,
              product_name: plan.product&.name,
              renews_at: renews_at_timestamp,
              expires_at: sub.expires_at&.to_i,
              unit_amount: plan.unit_amount,
              currency: plan.currency
            }
          end.compact

          render_json_dump processed_subscriptions

        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      def destroy
        begin
          subscription = ::Stripe::Subscription.update(params[:id], { cancel_at_period_end: true })
          if subscription
            render_json_dump subscription
          else
            render_json_error I18n.t("discourse_subscriptions.customer_not_found")
          end
        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      def update
        params.require(:payment_method)
        begin
          subscription = ::DiscourseSubscriptions::Subscription.find_by(external_id: params[:id])
          customer = ::DiscourseSubscriptions::Customer.find(subscription.customer_id)

          ::Stripe::PaymentMethod.attach(params[:payment_method], { customer: customer.customer_id })

          ::Stripe::Subscription.update(
            params[:id],
            { default_payment_method: params[:payment_method] },
            )
          render json: success_json
        rescue ::Stripe::InvalidRequestError
          render_json_error I18n.t("discourse_subscriptions.card.invalid")
        end
      end
    end
  end
end
