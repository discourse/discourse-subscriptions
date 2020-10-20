# frozen_string_literal: true

module DiscourseSubscriptions
  class PlansController < ::ApplicationController
    include DiscourseSubscriptions::Stripe

    before_action :set_api_key

    def index
      begin
        if params[:product_id].present?
          plans = ::Stripe::Price.list(active: true, product: params[:product_id])
        else
          plans = ::Stripe::Price.list(active: true)
        end

        render_json_dump serialize(plans)
      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
    end

    private

    def serialize(plans)
      serialized = plans[:data].map do |plan|
        plan.to_h.slice(:id, :unit_amount, :currency, :type, :recurring)
      end.sort_by { |plan| plan[:amount] }
    end
  end
end
