module DiscoursePayments
  class ChargesController < ActionController::Base
    skip_before_filter :verify_authenticity_token, only: [:create]

    def create
      # badge = Badge.find_by_name('Consumer Defender')
      #
      # if badge.nil?
      #   head 422 and return
      # end

      customer = Stripe::Customer.create(
       :email => 'joe@example.com',
       :source  => params[:stripeToken]
      )

      charge = Stripe::Charge.create(
        :customer    => customer.id,
        :amount      => 1001,
        :description => 'Consumer Defender',
        :currency    => 'aud'
      )

      # BadgeGranter.grant(badge, current_user)

      render :json => { status: 'OK' }
    end
  end
end
