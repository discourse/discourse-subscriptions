# frozen_string_literal: true

module Jobs
  class RefreshCampaignData < ::Jobs::Scheduled
    every 30.minutes

    def execute(args)
      Campaign.refresh_data if SiteSetting.discourse_subscriptions_campaign_enabled
    end
  end
end
