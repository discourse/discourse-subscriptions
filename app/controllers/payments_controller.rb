# frozen_string_literal: true

module DiscourseSubscriptions
  class PaymentsController < ::ApplicationController
    include DiscourseSubscriptions::Stripe

    skip_before_action :verify_authenticity_token, only: [:create]
    before_action :set_api_key

    requires_login

    def create
      begin
        customer = ::Stripe::Customer.create(
          email: current_user.email,
        )

        DiscourseSubscriptions::Customer.create(
          user_id: current_user.id,
          customer_id: customer[:id],
        )

        payment = ::Stripe::PaymentIntent.create(
          payment_method_types: ['card'],
          payment_method: params[:payment_method],
          amount: params[:amount],
          currency: params[:currency],
          confirm: true,
          customer: customer[:id],
        )

        render_json_dump payment

      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      rescue ::Stripe::CardError => e
        render_json_error 'Card Declined'
      end
    end
  end
end
