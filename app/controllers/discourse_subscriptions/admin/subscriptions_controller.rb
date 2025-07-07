# frozen_string_literal: true

module DiscourseSubscriptions
  module Admin
    class SubscriptionsController < ::Admin::AdminController
      requires_plugin DiscourseSubscriptions::PLUGIN_NAME

      include DiscourseSubscriptions::Stripe
      include DiscourseSubscriptions::Group
      before_action :set_api_key

      PAGE_SIZE = 50

      # In app/controllers/discourse_subscriptions/admin/subscriptions_controller.rb

      def index
        begin
          offset = params[:offset].to_i

          local_subscriptions = ::DiscourseSubscriptions::Subscription
                                  .joins(customer: :user)
                                  .order(created_at: :desc)

          if params[:username].present?
            local_subscriptions = local_subscriptions.where("users.username_lower = ?", params[:username].downcase)
          end

          total_subscriptions = local_subscriptions.count
          more_records = total_subscriptions > (offset + PAGE_SIZE)

          local_subscriptions = local_subscriptions.limit(PAGE_SIZE).offset(offset)

          all_subscriptions = []
          all_plans = is_stripe_configured? ? ::Stripe::Price.list(limit: 100, active: true, expand: ['data.product']) : []

          local_subscriptions.each do |sub|
            user_obj = sub.customer&.user
            next unless user_obj

            serialized_sub = {
              id: sub.external_id, provider: sub.provider.capitalize, status: sub.status,
              user: { id: user_obj.id, username: user_obj.username, avatar_template: user_obj.avatar_template_url },
              created_at: sub.created_at.to_i, expires_at: sub.expires_at&.to_i,
              unit_amount: nil, currency: nil
            }
            plan = all_plans.find { |p| p.id == sub.plan_id }

            if sub.provider == 'Stripe' && is_stripe_configured?
              begin
                api_sub = ::Stripe::Subscription.retrieve({ id: sub.external_id, expand: ['plan.product'] })
                plan ||= api_sub&.plan
                serialized_sub[:status] = api_sub.status if api_sub
                serialized_sub[:expires_at] = api_sub.cancel_at_period_end ? api_sub.current_period_end : nil if api_sub
              rescue ::Stripe::InvalidRequestError
                serialized_sub[:status] = 'not_in_stripe'
              end
            end

            if plan
              serialized_sub.merge!(plan_name: plan.product&.name, plan_nickname: plan.nickname, unit_amount: plan.unit_amount, currency: plan.currency)
            end
            all_subscriptions << serialized_sub
          end

          render json: {
            subscriptions: all_subscriptions,
            meta: {
              more: more_records,
              offset: offset + PAGE_SIZE,
              username: params[:username].presence
            }
          }

        rescue => e
          # --- THIS IS THE NEW, DETAILED LOGGING CODE ---
          Rails.logger.error("Discourse Subscriptions Error in Admin::SubscriptionsController#index")
          Rails.logger.error("Error Class: #{e.class.name}")
          Rails.logger.error("Error Message: #{e.message}")
          Rails.logger.error("Backtrace:\n#{e.backtrace.join("\n")}")

          # Render a user-friendly error to the frontend
          render_json_error("An unexpected server error occurred. Please check the server logs for detailed information.")
        end
      end

      def grant
        params.require(%i[username plan_id])
        begin
          user = ::User.find_by_username(params[:username])
          return render_json_error("User not found.") unless user

          plan = ::Stripe::Price.retrieve(params[:plan_id])
          return render_json_error("Plan not found.") unless plan

          transaction = {
            id: "manual_#{SecureRandom.hex(8)}",
            customer: "cus_manual_#{user.id}"
          }

          finalize_discourse_subscription(transaction, plan, user, params[:duration])
          render json: success_json

        rescue ActiveRecord::RecordInvalid => e
          render_json_error(e.record.errors.full_messages.join(", "))
        rescue => e
          render_json_error(e.message)
        end
      end

      private

      def safely_remove_user_from_group(user, group_to_remove_from, current_sub_id)
        other_subscriptions = ::DiscourseSubscriptions::Subscription
                                .joins(:customer)
                                .where(discourse_subscriptions_customers: { user_id: user.id })
                                .where(status: 'active')
                                .where.not(id: current_sub_id)

        has_other_access = other_subscriptions.any? do |sub|
          if sub.plan_id.present?
            begin
              other_plan = ::Stripe::Price.retrieve(sub.plan_id)
              other_group = plan_group(other_plan)
              other_group&.id == group_to_remove_from.id
            rescue ::Stripe::InvalidRequestError
              false
            end
          else
            false
          end
        end

        unless has_other_access
          group_to_remove_from.remove(user)
        end
      end

      def finalize_discourse_subscription(transaction, plan, user, duration_in_days = nil)
        raise ArgumentError, "User cannot be nil" if user.nil?
        raise ArgumentError, "Plan cannot be nil" if plan.nil?

        provider_name = 'manual'
        group = plan_group(plan)
        group&.add(user)

        duration = duration_in_days.present? ? duration_in_days.to_i : nil
        expires_at = duration.present? && duration > 0 ? duration.days.from_now : nil

        customer = ::DiscourseSubscriptions::Customer.find_or_create_by!(user_id: user.id) do |c|
          c.customer_id = transaction[:customer]
        end

        customer.update!(product_id: plan.product)

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
