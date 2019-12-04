# frozen_string_literal: true

module DiscourseSubscriptions
  class PatronsController < ::ApplicationController
    include DiscourseSubscriptions::Stripe

    skip_before_action :verify_authenticity_token, only: [:create]
    before_action :set_api_key

    def index
      result = { email: '' }

      if current_user
        result[:email] = current_user.email
      end

      render json: result
    end

    def create
      begin

        response = ::Stripe::PaymentIntent.create(
          amount: param_currency_to_number,
          currency: SiteSetting.discourse_patrons_currency,
          payment_method_types: ['card'],
          payment_method: params[:payment_method_id],
          description: SiteSetting.discourse_patrons_payment_description,
          receipt_email: params[:receipt_email],
          confirm: true,
          metadata: { user_id: user_id }
        )

      rescue ::Stripe::InvalidRequestError => e
        response = { error: e }
      rescue ::Stripe::CardError => e
        response = { error: 'Card Declined' }
      end

      render json: response
    end

    private

    def param_currency_to_number
      params[:amount].to_s.sub('.', '').to_i
    end

    def user_id
      if current_user
        current_user.id
      end
    end
  end
end
