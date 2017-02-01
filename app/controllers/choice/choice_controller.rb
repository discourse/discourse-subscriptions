module Choice
  class ChoiceController < Choice::ApplicationController
    def create
      customer = Stripe::Customer.create(
       :email => params[:stripeEmail],
       :source  => params[:stripeToken]
      )

      charge = Stripe::Charge.create(
        :customer    => customer.id,
        :amount      => params[:amount],
        :description => 'Consumer Defender',
        :currency    => 'aud'
      )

      BadgeGranter.grant(consumer_defender_badge, current_user)

      head :created
    end

    private

    def consumer_defender_badge
      Badge.find_by_name('Consumer Defender')
    end
  end
end
