# frozen_string_literal: true

module Jobs
  class RefreshSubscriptionsCampaignData < ::Jobs::Scheduled
    every 30.minutes

    def execute(args)
      return unless SiteSetting.discourse_subscriptions_campaign_enabled
      DiscourseSubscriptions::Campaign.new.refresh_data
    end
  end
end
