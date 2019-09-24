# frozen_string_literal: true

module DiscoursePatrons
  class PlansController < ::Admin::AdminController
    include DiscoursePatrons::Stripe

    before_action :set_api_key

    def create
      plan = ::Stripe::Plan.create(
        amount: params[:amount],
        interval: params[:interval],
        product: {
          name: 'Gold special',
        },
        currency: SiteSetting.discourse_patrons_currency,
        id: 'gold-special',
      )

      plan.to_json
    end
  end
end
