# frozen_string_literal: true

module DiscourseSubscriptions
  module Admin
    class SubscriptionsController < ::ApplicationController
      requires_plugin DiscourseSubscriptions::PLUGIN_NAME

      include DiscourseSubscriptions::Stripe
      include DiscourseSubscriptions::Group
      before_action :set_api_key

      def index
        begin
          local_subscriptions = ::DiscourseSubscriptions::Subscription.where.not(status: %w[revoked canceled]).includes(customer: :user).order(created_at: :desc)
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
              user_obj = sub.customer&.user
              plan = all_plans.find { |p| p.id == sub.plan_id }
              next unless plan&.product && user_obj
              {
                id: sub.external_id,
                status: sub.status,
                user: { id: user_obj.id, username: user_obj.username, avatar_template: user_obj.avatar_template },
                plan: { product: { name: plan.product.name } },
                amount_dollars: plan.unit_amount / 100.0,
                currency: plan.currency,
                created_at: sub.created_at.to_i
              }
            end.compact
            processed_data[:razorpay] = razorpay_purchases
          end
          render_json_dump(processed_data)
        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      def destroy
        params.require(:id)
        begin
          subscription = ::Stripe::Subscription.update(params[:id], { cancel_at_period_end: true })
          local_sub = ::DiscourseSubscriptions::Subscription.find_by(external_id: params[:id])
          local_sub&.update(status: subscription.status)
          render_json_dump subscription
        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      def revoke
        params.require(:id)
        begin
          subscription = ::DiscourseSubscriptions::Subscription.find_by(external_id: params[:id])
          return render_json_error("Subscription not found") unless subscription
          user = subscription.customer&.user
          plan = ::Stripe::Price.retrieve(subscription.plan_id) if subscription.plan_id
          group = plan_group(plan) if plan
          if user && group
            group.remove(user)
            subscription.update(status: 'revoked')
            render json: success_json
          else
            render_json_error("Could not find user or group for this subscription.")
          end
        rescue => e
          render_json_error(e.message)
        end
      end

      def grant
        params.require(%i[username plan_id])
        begin
          user = User.find_by_username(params[:username])
          return render_json_error("User not found.") unless user
          plan = ::Stripe::Price.retrieve(params[:plan_id])
          return render_json_error("Plan not found.") unless plan
          transaction = {
            id: "manual_#{SecureRandom.hex(8)}",
            customer: "cus_manual_#{user.id}"
          }
          finalize_discourse_subscription(transaction, plan, user, params[:duration])
          render json: success_json
        rescue ::Stripe::InvalidRequestError => e
          render_json_error(e.message)
        end
      end

      private

      def finalize_discourse_subscription(transaction, plan, user, duration_in_days = nil)
        provider_name = 'manual'
        group_name = plan.metadata.group_name if plan.metadata
        if group_name.present?
          group = ::Group.find_by(name: group_name)
          group&.add(user) if group
        end
        duration = duration_in_days.present? ? duration_in_days.to_i : nil
        expires_at = duration.present? && duration > 0 ? duration.days.from_now : nil
        customer = ::DiscourseSubscriptions::Customer.find_or_create_by!(user_id: user.id) do |c|
          c.customer_id = transaction[:customer]
        end
        customer.update!(
          customer_id: transaction[:customer],
          product_id: plan.product
        )
        ::DiscourseSubscriptions::Subscription.create!(
          customer_id: customer.id,
          external_id: transaction[:id],
          status: "active",
          provider: provider_name,
          plan_id: plan.id,
          duration: duration,
          expires_at: expires_at
        )
      end
    end
  end
end
