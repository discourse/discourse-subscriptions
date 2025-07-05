# frozen_string_literal: true

module ::Jobs
  class CheckExpiredSubscriptions < ::Jobs::Scheduled
    every 1.day # You can change this to 1.hour for more frequent checks

    def execute(args)
      return unless SiteSetting.discourse_subscriptions_enabled

      # Find all subscriptions that have an expiry date in the past
      # and are still marked as 'active'
      expired_subscriptions = ::DiscourseSubscriptions::Subscription
                                .where(status: 'active')
                                .where.not(expires_at: nil)
                                .where("expires_at < ?", Time.zone.now)

      return if expired_subscriptions.empty?

      # We need to get all the plan details from Stripe
      all_plans = ::Stripe::Price.list(limit: 100, active: true)

      expired_subscriptions.each do |sub|
        begin
          user = sub.customer&.user
          plan = all_plans.find { |p| p.id == sub.plan_id }

          if user && plan
            group_name = plan.metadata&.group_name
            group = ::Group.find_by_name(group_name) if group_name.present?

            if group
              Rails.logger.info("[Subscriptions] Expiring user #{user.username} from group #{group.name} for subscription #{sub.external_id}")
              group.remove(user)
            end
          end

          # Mark the subscription as expired so we don't process it again
          sub.update(status: 'expired')

        rescue => e
          Rails.logger.error("Failed to process expired subscription #{sub.id}. Error: #{e.message}")
          next
        end
      end
    end
  end
end
