require_dependency 'discourse'

module DiscoursePayments
  class ChargesController < ActionController::Base
    include CurrentUser

    skip_before_filter :verify_authenticity_token, only: [:create]

    def create
      # badge = Badge.find_by_name('Consumer Defender')
      #
      # if badge.nil?
      #   head 422 and return
      # end

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

      # BadgeGranter.grant(badge, current_user)

      render :json => charge
    end
  end
end
