require_dependency 'discourse'

module DiscourseDonations
  class ChargesController < ActionController::Base
    include CurrentUser

    skip_before_filter :verify_authenticity_token, only: [:create]

    def create
      if email.nil?
        response = {'message' => 'Please enter your email address'}
      elsif create_account && params[:username].nil?
        response = {'message' => 'Please enter a username'}
      else
        Stripe.api_key = SiteSetting.discourse_donations_secret_key
        currency = SiteSetting.discourse_donations_currency

        customer = Stripe::Customer.create(
         :email => email,
         :source  => params[:stripeToken]
        )

        response = Stripe::Charge.create(
          :customer    => customer.id,
          :amount      => params[:amount],
          :description => SiteSetting.discourse_donations_description,
          :currency    => currency
        )

        response['message'] = response['outcome']['seller_message']
      end

      render :json => response
    end

    private

    def create_account
      params[:create_account]
    end

    def email
      params[:email] || current_user.try(:email)
    end
  end
end
