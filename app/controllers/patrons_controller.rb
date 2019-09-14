# frozen_string_literal: true

module DiscoursePatrons
  class PatronsController < ::ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]
    before_action :set_api_key

    def index
      result = { email: '' }

      if current_user
        result[:email] = current_user.email
      end

      render json: result
    end

    def show
      payment_intent = Stripe::PaymentIntent.retrieve(params[:pid])

      if current_user && (current_user.admin || payment_intent[:customer] == current_user.id)
        result = payment_intent
      else
        result = { error: 'Not found' }
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
          customer: user_id
        )

        Payment.create(
          user_id: response[:customer],
          payment_intent_id: response[:id],
          receipt_email: response[:receipt_email],
          url: response[:charges][:url],
          amount: response[:amount],
          currency: response[:currency]
        )

      rescue ::Stripe::InvalidRequestError => e
        response = { error: e }
      rescue ::Stripe::CardError => e
        response = { error: 'Card Declined' }
      end

      render json: response
    end

    private

    def set_api_key
      ::Stripe.api_key = SiteSetting.discourse_patrons_secret_key
    end

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
