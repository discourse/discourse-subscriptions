require_dependency 'discourse'

module DiscourseDonations
  class CheckoutController < ActionController::Base
    include CurrentUser

    protect_from_forgery prepend: true
    protect_from_forgery with: :exception

    skip_before_action :verify_authenticity_token, only: [:create]

    def create
      Rails.logger.debug params.inspect
      Rails.logger.debug user_params.inspect

      output = { 'messages' => [], 'rewards' => [] }
      payment = DiscourseDonations::Stripe.new(secret_key, stripe_options)

      begin
        charge = payment.checkoutCharge(user_params[:stripeEmail],
                                        user_params[:stripeToken],
                                        user_params[:amount])
      rescue ::Stripe::CardError => e
        err = e.json_body[:error]

        output['messages'] << "There was an error (#{err[:type]})."
        output['messages'] << "Error code: #{err[:code]}" if err[:code]
        output['messages'] << "Decline code: #{err[:decline_code]}" if err[:decline_code]
        output['messages'] << "Message: #{err[:message]}" if err[:message]

        render(:json => output) and return
      end

      if charge['paid']
        output['messages'] << I18n.t('donations.payment.success')
        output['rewards'] << { type: :group, name: group_name } if group_name
        output['rewards'] << { type: :badge, name: badge_name } if badge_name
      end

      render :json => output
    end

    private


    def reward?(payment)
      payment.present? && payment.successful?
    end

    def group_name
      SiteSetting.discourse_donations_reward_group_name
    end

    def badge_name
      SiteSetting.discourse_donations_reward_badge_name
    end

    def secret_key
      SiteSetting.discourse_donations_secret_key
    end

    def user_params
      params.permit(:amount,
                    :stripeToken,
                    :stripeTokenType,
                    :stripeEmail,
                    :stripeBillingName,
                    :stripeBillingAddressLine1,
                    :stripeBillingAddressZip,
                    :stripeBillingAddressState,
                    :stripeBillingAddressCity,
                    :stripeBillingAddressCountry,
                    :stripeBillingAddressCountryCode,
                    :stripeShippingName,
                    :stripeShippingAddressLine1,
                    :stripeShippingAddressZip,
                    :stripeShippingAddressState,
                    :stripeShippingAddressCity,
                    :stripeShippingAddressCountry,
                    :stripeShippingAddressCountryCode

      )
    end

    def stripe_options
      {
          description: SiteSetting.discourse_donations_description,
          currency: SiteSetting.discourse_donations_currency
      }
    end
  end
end
