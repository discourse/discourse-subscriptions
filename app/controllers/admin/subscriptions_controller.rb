# frozen_string_literal: true

module DiscoursePatrons
  class SubscriptionsController < ::Admin::AdminController
    def index
      ::Stripe.api_key = SiteSetting.discourse_patrons_secret_key

      subscriptions = ::Stripe::Subscription.list

      subscriptions.to_json
    end
  end
end
