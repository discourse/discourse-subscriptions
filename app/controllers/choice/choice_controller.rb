module Choice
  class ChoiceController < Choice::ApplicationController
    def create
      badge = Badge.find_by_name('Consumer Defender')

      if badge.nil?
        head 422 and return
      end

      customer = Stripe::Customer.create(
       :email => params[:stripeEmail],
       :source  => params[:stripeToken]
      )

      charge = Stripe::Charge.create(
        :customer    => customer.id,
        :amount      => 1000,
        :description => 'Consumer Defender',
        :currency    => 'aud'
      )

      BadgeGranter.grant(badge, current_user)

      render :json => { status: 'OK' }
    end
  end
end
