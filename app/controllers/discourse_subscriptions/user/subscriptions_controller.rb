# frozen_string_literal: true

module DiscourseSubscriptions
  module User
    class SubscriptionsController < ::ApplicationController
      include DiscourseSubscriptions::Stripe
      include DiscourseSubscriptions::Group

      requires_plugin DiscourseSubscriptions::PLUGIN_NAME

      before_action :set_api_key
      requires_login

      def index
        begin
          customer = Customer.find_by(user_id: current_user.id)
          return render json: [] unless customer

          local_subscriptions = ::DiscourseSubscriptions::Subscription.where(customer_id: customer.id).order(created_at: :desc)

          all_plans = is_stripe_configured? ? ::Stripe::Price.list(limit: 100, active: true, expand: ['data.product']) : []

          processed_subscriptions = local_subscriptions.map do |sub|
            plan = all_plans.find { |p| p.id == sub.plan_id }
            next unless plan

            {
              id: sub.external_id,
              provider: sub.provider,
              status: sub.status,
              plan_nickname: plan.nickname,
              product_name: plan.product&.name,
              renews_at: (sub.provider == 'Stripe' && sub.status == 'active') ? ::Stripe::Subscription.retrieve(sub.external_id)&.current_period_end : nil,
              expires_at: sub.expires_at&.to_i,
              # --- THIS IS THE FIX ---
              unit_amount: plan.unit_amount,
              currency: plan.currency
              # ---------------------
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
