# frozen_string_literal: true

module DiscoursePatrons
  class SubscriptionsController < ::ApplicationController
    include DiscoursePatrons::Stripe

    before_action :set_api_key

    def create
      subscription = ::Stripe::Subscription.create(
        customer: params[:customer],
        items: [
          { plan: params[:plan] },
        ]
      )

      render_json_dump subscription
    end
  end
end
