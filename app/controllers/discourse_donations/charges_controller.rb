require_dependency 'discourse'

module DiscourseDonations
  class ChargesController < ActionController::Base
    include CurrentUser

    skip_before_filter :verify_authenticity_token, only: [:create]

    def create
      Stripe.api_key = SiteSetting.discourse_donations_secret_key
      currency = SiteSetting.discourse_donations_currency

      customer = Stripe::Customer.create(
       :email => params[:email] || current_user.email,
       :source  => params[:stripeToken]
      )

      charge = Stripe::Charge.create(
        :customer    => customer.id,
        :amount      => params[:amount],
        :description => SiteSetting.discourse_donations_description,
        :currency    => currency
      )

      render :json => charge
    end
  end
end
