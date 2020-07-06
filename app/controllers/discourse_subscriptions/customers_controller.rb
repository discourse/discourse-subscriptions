# frozen_string_literal: true

module DiscourseSubscriptions
  class CustomersController < ::ApplicationController
    include DiscourseSubscriptions::Stripe

    before_action :set_api_key

    def create
      begin
        customer = ::Stripe::Customer.create(
          email: current_user.email,
          source: params[:source]
        )

        render_json_dump customer

      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
    end
  end
end
