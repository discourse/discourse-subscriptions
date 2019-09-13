# frozen_string_literal: true

module DiscoursePatrons
  class PatronsController < ::ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]

    def index
      result = { email: '' }

      if current_user
        result[:email] = current_user.email
      end

      render json: result
    end

    def create
      ::Stripe.api_key = SiteSetting.discourse_patrons_secret_key

      begin

        response = ::Stripe::PaymentIntent.create(
          amount: param_currency_to_number,
          currency: SiteSetting.discourse_patrons_currency,
          payment_method_types: ['card'],
          payment_method: params[:paymentMethodId],
          description: SiteSetting.discourse_patrons_payment_description,
          confirm: true,
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
  end
end
