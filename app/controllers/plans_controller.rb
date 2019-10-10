# frozen_string_literal: true

module DiscoursePatrons
  class PlansController < ::ApplicationController
    include DiscoursePatrons::Stripe

    before_action :set_api_key

    def index
      plans = ::Stripe::Plan.list
      render json: plans.data
    end
  end
end
