# frozen_string_literal: true

module DiscoursePatrons
  class PatronsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]

    def index
      result = {}
      render json: result
    end

    def create
      ::Stripe.api_key = SiteSetting.discourse_patrons_secret_key

      begin

        response = ::Stripe::PaymentIntent.create(
          amount: params[:amount],
          currency: SiteSetting.discourse_patrons_currency,
          payment_method_types: ['card'],
          payment_method: params[:paymentMethodId],
          confirm: true,
        )

      rescue ::Stripe::InvalidRequestError => e
        response = { error: e }
      rescue ::Stripe::CardError => e
        response = { error: 'Card Declined' }
      end

      render json: response
    end
  end
end
