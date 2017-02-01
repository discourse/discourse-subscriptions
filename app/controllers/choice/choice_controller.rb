module Choice
  class ChoiceController < Choice::ApplicationController
    def create
      @badge = consumer_defender_badge
      @user = @discourse_api.client.user

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



      head :created
    end

    private

    def consumer_defender_badge
      Discourse.badges['badges'].select { |b| b['name'] == 'Consumer Defender' }.first
    end
  end
end
