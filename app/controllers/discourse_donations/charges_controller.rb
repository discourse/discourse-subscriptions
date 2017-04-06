require_dependency 'discourse'

module DiscourseDonations
  class ChargesController < ActionController::Base
    include CurrentUser

    skip_before_filter :verify_authenticity_token, only: [:create]

    def create
      if email.nil? || email.empty?
        response = {}
      else
        payment = DiscourseDonations::Stripe.new(secret_key, stripe_options)
        response = payment.charge(email, params)
      end

      render :json => response
    end

    private

    def secret_key
      SiteSetting.discourse_donations_secret_key
    end

    def stripe_options
      {
        description: SiteSetting.discourse_donations_description,
        currency: SiteSetting.discourse_donations_currency
      }
    end

    def email
      params[:email] || current_user.try(:email)
    end
  end
end
