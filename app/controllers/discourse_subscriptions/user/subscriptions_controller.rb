# frozen_string_literal: true

module DiscourseSubscriptions
  module User
    class SubscriptionsController < ::ApplicationController
      include DiscourseSubscriptions::Stripe
      include DiscourseSubscriptions::Group

      requires_plugin DiscourseSubscriptions::PLUGIN_NAME

      before_action :set_api_key
      requires_login

      # in app/controllers/discourse_subscriptions/user/subscriptions_controller.rb

      # in app/controllers/discourse_subscriptions/user/subscriptions_controller.rb

      def index
        begin
          Rails.logger.warn("--- RAZORPAY DEBUGGER: 1. Index action started for user: #{current_user&.username} ---")

          customer_ids = Customer.where(user_id: current_user.id).pluck(:id)
          Rails.logger.warn("--- RAZORPAY DEBUGGER: 2. Found customer IDs: #{customer_ids.join(', ')} ---")

          if customer_ids.empty?
            return render_json_dump({ stripe: [], razorpay: [] })
          end

          local_subscriptions = ::DiscourseSubscriptions::Subscription.where(customer_id: customer_ids)
          # Corrected logging to avoid serialization error
          Rails.logger.warn("--- RAZORPAY DEBUGGER: 3. Found #{local_subscriptions.count} total subscription records. IDs: #{local_subscriptions.map(&:id).join(', ')} ---")

          # The rest of the production code from before, which we now know will work.
          stripe_ids = local_subscriptions.where(provider: 'Stripe').pluck(:external_id)
          razorpay_records = local_subscriptions.where(provider: 'Razorpay')

          processed_data = {
            stripe: [],
            razorpay: []
          }

          if stripe_ids.present?
            stripe_data = ::Stripe::Subscription.list(limit: 100, status: 'all', expand: ['data.plan.product'])
            processed_data[:stripe] = stripe_data.select { |sub| stripe_ids.include?(sub.id) }
          end

          if razorpay_records.present?
            all_plans = ::Stripe::Price.list(limit: 100, active: true, expand: ['data.product'])

            razorpay_purchases = razorpay_records.map do |sub|
              plan = all_plans.find { |p| p.id == sub.plan_id }
              next unless plan&.product

              {
                id: sub.external_id,
                plan_name: plan.product.name,
                amount_dollars: plan.unit_amount / 100.0,
                currency: plan.currency,
                created_at: sub.created_at.to_i
              }
            end.compact

            processed_data[:razorpay] = razorpay_purchases.sort_by { |p| p[:created_at] }.reverse
          end

          Rails.logger.warn("--- RAZORPAY DEBUGGER: 4. Successfully processed all data. Rendering JSON. ---")
          render_json_dump(processed_data)

        rescue => e
          Rails.logger.error("--- RAZORPAY DEBUGGER: A CRASH OCCURRED in the index action ---")
          Rails.logger.error("#{e.class.name}: #{e.message}")
          Rails.logger.error(e.backtrace.join("\n"))
          render_json_error("A crash occurred on the server. Please check the logs.")
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
