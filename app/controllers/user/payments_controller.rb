# frozen_string_literal: true

module DiscourseSubscriptions
  module User
    class PaymentsController < ::ApplicationController
      include DiscourseSubscriptions::Stripe
      before_action :set_api_key
      requires_login

      def index
        begin
          customer = DiscourseSubscriptions::Customer.find_by(user_id: current_user.id, product_id: nil)

          data = []

          if customer.present?
            payments = ::Stripe::PaymentIntent.list(customer: customer[:customer_id])
            data = payments[:data]
          end

          render_json_dump data

        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end
    end
  end
end
