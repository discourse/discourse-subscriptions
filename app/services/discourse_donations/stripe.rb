RECURRING_DONATION_PRODUCT_ID = 'discourse_donation_recurring'

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

    def charge(user = nil, opts)
      customer = customer(user, opts[:email], opts[:token])

      @charge = ::Stripe::Charge.create(
        customer: customer.id,
        amount: opts[:amount],
        description: @description,
        currency: @currency
      )

      @charge
    end

    def subscribe(user = nil, opts)
      customer = customer(user, opts[:email], opts[:token])

      plans = ::Stripe::Plan.list
      type = opts[:type]
      plan_id = create_plan_id(type)

      unless plans.data && plans.data.any? { |p| p['id'] === plan_id }
        result = create_plan(type, opts[:amount])
        plan_id = result['id']
      end

      @subscription = ::Stripe::Subscription.create(
        customer: customer.id,
        items: [{ plan: plan_id }]
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

    def create_plan(type, amount)
      id = create_plan_id(type)
      nickname = id.gsub(/_/, ' ').titleize

      products = ::Stripe::Product.list(type: 'service')

      if products['data'] && products['data'].any? { |p| p['id'] === RECURRING_DONATION_PRODUCT_ID }
        product = RECURRING_DONATION_PRODUCT_ID
      else
        result = create_product
        product = result['id']
      end

      ::Stripe::Plan.create(
        id: id,
        nickname: nickname,
        interval: type.tr('ly', ''),
        currency: @currency,
        product: product,
        amount: amount.to_i
      )
    end

    def create_product
      ::Stripe::Product.create(
        id: RECURRING_DONATION_PRODUCT_ID,
        name: "Discourse Donation Recurring",
        type: 'service'
      )
    end

    def create_plan_id(type)
      "discourse_donation_recurring_#{type}"
    end
  end
end
