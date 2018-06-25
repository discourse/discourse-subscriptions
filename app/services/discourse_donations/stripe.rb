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
        currency: @currency,
        receipt_email: customer.email
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

    def list(user)
      customer = customer(user)
      result = {}

      raw_invoices = ::Stripe::Invoice.list(customer: customer.id)
      raw_invoices = raw_invoices.is_a?(Object) ? raw_invoices['data'] : []

      raw_charges = ::Stripe::Charge.list(customer: customer.id)
      raw_charges = raw_charges.is_a?(Object) ? raw_charges['data'] : []

      if raw_invoices.any?
        raw_subscriptions = ::Stripe::Subscription.list(customer: customer.id)['data']

        if raw_subscriptions.any?
          subscriptions = []

          raw_subscriptions.each do |subscription|
            invoices = raw_invoices.select do |invoice|
              invoice['subscription'] === subscription['id']
            end

            subscriptions.push(
              subscription: subscription,
              invoices: invoices
            )
          end

          result[:subscriptions] = subscriptions
        end

        ## filter out any charges related to subscriptions
        raw_invoice_ids = raw_invoices.map { |i| i['id'] }
        raw_charges = raw_charges.select { |c| raw_invoice_ids.exclude?(c['invoice']) }
      end

      if raw_charges.any?
        result[:charges] = raw_charges
      end

      result
    end

    def customer(user, email = nil, source = nil)
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

      if products['data'] && products['data'].any? { |p| p['id'] === product_id }
        product = product_id
      else
        result = create_product
        product = result['id']
      end

      ::Stripe::Plan.create(
        id: id,
        nickname: nickname,
        interval: type,
        currency: @currency,
        product: product,
        amount: amount.to_i
      )
    end

    def create_product
      ::Stripe::Product.create(
        id: product_id,
        name: product_name,
        type: 'service'
      )
    end

    def product_id
      @product_id ||= "#{SiteSetting.title}_recurring_donation"
    end

    def product_name
      @product_name ||= I18n.t('discourse_donations.recurring', site_title: SiteSetting.title)
    end

    def create_plan_id(type)
      "discourse_donation_recurring_#{type}"
    end
  end
end
