module DiscourseDonations
  class Stripe
    attr_reader :charge, :currency, :description

    def initialize(secret_key, opts)
      ::Stripe.api_key = secret_key
      @description = opts[:description]
      @currency = opts[:currency]
    end

    def checkoutCharge(user = nil, email, token, amount)
      customer = customer(user,
        email: email,
        source: token,
        create: true
      )

      return if !customer

      charge = ::Stripe::Charge.create(
        customer: customer.id,
        amount: amount,
        description: @description,
        currency: @currency
      )

      charge
    end

    def charge(user = nil, opts)
      customer = customer(user,
        email: opts[:email],
        source: opts[:token],
        create: true
      )

      return if !customer

      metadata = {
        discourse_cause: opts[:cause]
      }

      if (user)
        metadata[:discourse_user_id] = user.id
      end

      @charge = ::Stripe::Charge.create(
        customer: customer.id,
        amount: opts[:amount],
        description: @description,
        currency: @currency,
        receipt_email: customer.email,
        metadata: metadata
      )

      @charge
    end

    def subscribe(user = nil, opts)
      customer = customer(user,
        email: opts[:email],
        source: opts[:token],
        create: true
      )

      return if !customer

      type = opts[:type]
      amount = opts[:amount]

      plans = ::Stripe::Plan.list
      plan_id = create_plan_id(type, amount)

      unless plans.data && plans.data.any? { |p| p['id'] === plan_id }
        result = create_plan(type, amount)

        plan_id = result['id']
      end

      ::Stripe::Subscription.create(
        customer: customer.id,
        items: [{
          plan: plan_id
        }],
        metadata: {
          discourse_cause: opts[:cause],
          discourse_user_id: user.id
        }
      )
    end

    def list(user, opts = {})
      customer = customer(user, opts)

      return if !customer

      result = { customer: customer }

      raw_invoices = ::Stripe::Invoice.list(customer: customer.id)
      raw_invoices = raw_invoices.is_a?(Object) ? raw_invoices['data'] : []

      raw_charges = ::Stripe::Charge.list(customer: customer.id)
      raw_charges = raw_charges.is_a?(Object) ? raw_charges['data'] : []

      if raw_invoices.any?
        raw_subscriptions = ::Stripe::Subscription.list(customer: customer.id, status: 'all')
        raw_subscriptions = raw_subscriptions.is_a?(Object) ? raw_subscriptions['data'] : []

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

    def invoices_for_subscription(user, opts)
      customer = customer(user,
        email: opts[:email]
      )

      invoices = []

      if customer
        result = ::Stripe::Invoice.list(
          customer: customer.id,
          subscription: opts[:subscription_id]
        )

        invoices = result['data'] if result['data']
      end

      invoices
    end

    def cancel_subscription(subscription_id)
      if subscription = ::Stripe::Subscription.retrieve(subscription_id)
        result = subscription.delete

        if result['status'] === 'canceled'
          { success: true, subscription: subscription }
        else
          { success: false, message: I18n.t('donations.subscription.error.not_cancelled') }
        end
      else
        { success: false, message: I18n.t('donations.subscription.error.not_found') }
      end
    end

    def customer(user, opts = {})
      customer = nil

      if user && user.stripe_customer_id
        begin
          customer = ::Stripe::Customer.retrieve(user.stripe_customer_id)
        rescue ::Stripe::StripeError => e
          user.custom_fields['stripe_customer_id'] = nil
          user.save_custom_fields(true)
          customer = nil
        end
      end

      if !customer && opts[:email]
        begin
          customers = ::Stripe::Customer.list(email: opts[:email])

          if customers && customers['data']
            customer = customers['data'].first if customers['data'].any?
          end

          if customer && user
            user.custom_fields['stripe_customer_id'] = customer.id
            user.save_custom_fields(true)
          end
        rescue ::Stripe::StripeError => e
          customer = nil
        end
      end

      if !customer && opts[:create]
        customer_opts = {
          email: opts[:email],
          source: opts[:source]
        }

        if user
          customer_opts[:metadata] = {
            discourse_user_id: user.id
          }
        end

        customer = ::Stripe::Customer.create(customer_opts)

        if user
          user.custom_fields['stripe_customer_id'] = customer.id
          user.save_custom_fields(true)
        end
      end

      customer
    end

    def successful?
      @charge[:paid]
    end

    def create_plan(type, amount)
      id = create_plan_id(type, amount)
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
      @product_id ||= "#{SiteSetting.title}_recurring_donation".freeze
    end

    def product_name
      @product_name ||= I18n.t('donations.recurring', site_title: SiteSetting.title)
    end

    def create_plan_id(type, amount)
      "discourse_donation_recurring_#{type}_#{amount}".freeze
    end
  end
end
