# frozen_string_literal: true

module DiscoursePatrons
  module Admin
    class SubscriptionsController < ::Admin::AdminController
      include DiscoursePatrons::Stripe

      before_action :set_api_key

      def index
        subscriptions = ::Stripe::Subscription.list
        subscriptions.to_json
      end
    end
  end
end
