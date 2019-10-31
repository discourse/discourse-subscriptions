# frozen_string_literal: true

module DiscoursePatrons
  class PlansController < ::ApplicationController
    include DiscoursePatrons::Stripe

    before_action :set_api_key

    def index
      begin
        plans = ::Stripe::Plan.list(active: true)

        serialized = plans[:data].map do |plan|
          plan.to_h.slice(:id, :amount, :currency, :interval)
        end.sort_by { |plan| plan[:amount] }

        render_json_dump serialized

      rescue ::Stripe::InvalidRequestError => e
        return render_json_error e.message
      end
    end
  end
end
