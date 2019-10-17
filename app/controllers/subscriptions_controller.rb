# frozen_string_literal: true

module DiscoursePatrons
  class SubscriptionsController < ::ApplicationController
    include DiscoursePatrons::Stripe

    before_action :set_api_key

    def create
      begin
        subscription = ::Stripe::Subscription.create(
          customer: params[:customer],
          items: [
            { plan: params[:plan] },
          ]
        )

        if subscription_ok(subscription)
          # TODO: check group credentials
          group = Group.find_by_name('group-123')
          group.add(current_user)
        end

        render_json_dump subscription

      rescue ::Stripe::InvalidRequestError => e
        return render_json_error e.message
      end
    end

    private

    def subscription_ok(subscription)
      # ['active', 'trialing'].include?(subscription[:status])
      false
    end
  end
end
