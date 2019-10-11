# frozen_string_literal: true

module DiscoursePatrons
  class CustomersController < ::ApplicationController
    include DiscoursePatrons::Stripe

    before_action :set_api_key

    def create
      customer = ::Stripe::Customer.create(
        email: current_user.email,
        source: params[:source]
      )

      render_json_dump customer
    end
  end
end
