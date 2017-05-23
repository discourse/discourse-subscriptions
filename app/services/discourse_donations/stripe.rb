
module DiscourseDonations
  class Stripe
    attr_reader :charge, :currency, :description

    def initialize(secret_key, opts)
      ::Stripe.api_key = secret_key
      @description = opts[:description]
      @currency = opts[:currency]
    end

    def charge(email, opts)
      customer = ::Stripe::Customer.create(
        email: email,
        source: opts[:stripeToken]
      )
      @charge = ::Stripe::Charge.create(
        customer: customer.id,
        amount: opts[:amount],
        description: description,
        currency: currency
      )
      @charge
    end

    def subscribe(email, opts)
      customer = ::Stripe::Customer.create(email: email, source: opts[:stripeToken])
      @subscription = ::Stripe::Subscription.create(customer: customer.id, plan: opts[:plan])
      @subscription
    end

    def successful?
      @charge[:paid]
    end
  end
end
