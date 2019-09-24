# frozen_string_literal: true

module DiscoursePatrons
  class SubscriptionsController < ::Admin::AdminController
    include DiscoursePatrons::Stripe

    before_action :set_api_key

    def index
      subscriptions = ::Stripe::Subscription.list
      subscriptions.to_json
    end
  end
end
