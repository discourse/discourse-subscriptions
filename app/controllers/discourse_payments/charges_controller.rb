require_dependency 'discourse'

module DiscoursePayments
  class ChargesController < ActionController::Base
    include CurrentUser

    skip_before_filter :verify_authenticity_token, only: [:create]

    def create
      customer = Stripe::Customer.create(
       :email => current_user.email,
       :source  => params[:stripeToken]
      )

      charge = Stripe::Charge.create(
        :customer    => customer.id,
        :amount      => params[:amount],
        :description => 'Consumer Defender',
        :currency    => 'aud'
      )
      render :json => charge
    end
  end
end
