# frozen_string_literal: true

module Jobs
  class ManuallyUpdateCampaignData < ::Jobs::Base

    def execute(args)
      return unless SiteSetting.discourse_subscriptions_campaign_enabled
      DiscourseSubscriptions::Campaign.refresh_data
    end
  end
end
