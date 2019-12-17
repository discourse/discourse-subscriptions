# frozen_string_literal: true

module DiscourseSubscriptions
  class PaymentsController < ::ApplicationController
    include DiscourseSubscriptions::Stripe

    skip_before_action :verify_authenticity_token, only: [:create]
    before_action :set_api_key

    requires_login

    def create
      begin
        customer = DiscourseSubscriptions::Customer.where(user_id: current_user.id, product_id: nil).first_or_create do |c|
          new_customer = ::Stripe::Customer.create(
            email: current_user.email
          )

          c.customer_id = new_customer[:id]
        end

        payment = ::Stripe::PaymentIntent.create(
          payment_method_types: ['card'],
          payment_method: params[:payment_method],
          amount: params[:amount],
          currency: params[:currency],
          customer: customer[:customer_id],
          confirm: true
        )

        render_json_dump payment

      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      rescue ::Stripe::CardError => e
        render_json_error I18n.t('discourse_subscriptions.card.declined')
      end
    end
  end
end
