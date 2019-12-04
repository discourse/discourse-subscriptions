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

        DiscourseSubscriptions::Customer.create_customer(
          current_user,
          customer
        )

        render_json_dump customer

      rescue ::Stripe::InvalidRequestError => e
        return render_json_error e.message
      end
    end
  end
end
