module DiscourseDonations
  class Stripe
    attr_reader :charge, :currency, :description

    def initialize(secret_key, opts)
      ::Stripe.api_key = secret_key
      @description = opts[:description]
      @currency = opts[:currency]
    end

    def checkoutCharge(user = nil, email, token, amount)
      customer = customer(user, email, token)
      charge = ::Stripe::Charge.create(
        customer: customer.id,
        amount: amount,
        description: @description,
        currency: @currency
      )
      charge
    end

    def charge(user = nil, email, token, amount)
      customer = customer(user, email, token)
      @charge = ::Stripe::Charge.create(
        customer: customer.id,
        amount: amount,
        description: description,
        currency: currency
      )
      @charge
    end

    def subscribe(user = nil, email, opts)
      customer = customer(user, email, opts[:stripeToken])
      @subscription = ::Stripe::Subscription.create(
        customer: customer.id,
        plan: opts[:plan]
      )
      @subscription
    end

    def customer(user, email, source)
      if user && user.stripe_customer_id
        ::Stripe::Customer.retrieve(user.stripe_customer_id)
      else
        customer = ::Stripe::Customer.create(
          email: email,
          source: source
        )
        if user
          user.custom_fields['stripe_customer_id'] = customer.id
          user.save_custom_fields(true)
        end
        customer
      end
    end

    def successful?
      @charge[:paid]
    end
  end
end
