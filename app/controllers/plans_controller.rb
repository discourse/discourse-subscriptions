# frozen_string_literal: true

module DiscoursePatrons
  class PlansController < ::ApplicationController
    include DiscoursePatrons::Stripe

    before_action :set_api_key

    def index
      begin
        plans = ::Stripe::Plan.list(active: true)

        render_json_dump plans.data

      rescue ::Stripe::InvalidRequestError => e
        return render_json_error e.message
      end
    end
  end
end
