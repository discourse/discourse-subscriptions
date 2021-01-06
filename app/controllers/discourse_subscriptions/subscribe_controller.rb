# frozen_string_literal: true

module DiscourseSubscriptions
  class SubscribeController < ::ApplicationController
    include DiscourseSubscriptions::Stripe
    include DiscourseSubscriptions::Group
    before_action :set_api_key
    requires_login except: [:index, :show]

    def index
      begin
        product_ids = Product.all.pluck(:external_id)
        products = []

        if product_ids.present? && is_stripe_configured?
          response = ::Stripe::Product.list({
            ids: product_ids,
            active: true
          })

          products = response[:data].map do |p|
            serialize_product(p)
          end

        end

        render_json_dump products

      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
    end

    def show
      params.require(:id)
      begin
        product = ::Stripe::Product.retrieve(params[:id])
        plans = ::Stripe::Price.list(active: true, product: params[:id])

        response = {
          product: serialize_product(product),
          plans: serialize_plans(plans)
        }

        render_json_dump response
      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
    end

    def create
      params.require([:source, :plan])
      begin
        customer = create_customer(params[:source])
        plan = ::Stripe::Price.retrieve(params[:plan])
        promo_code = ::Stripe::PromotionCode.list({ code: params[:promo] }) if params[:promo].present?
        promo_code = promo_code[:data][0] if promo_code && promo_code[:data] # we assume promo codes have a unique name

        recurring_plan = plan[:type] == 'recurring'

        if recurring_plan
          trial_days = plan[:metadata][:trial_period_days] if plan[:metadata] && plan[:metadata][:trial_period_days]

          promo_code_id = promo_code[:id] if promo_code

          transaction = ::Stripe::Subscription.create(
            customer: customer[:id],
            items: [{ price: params[:plan] }],
            metadata: metadata_user,
            trial_period_days: trial_days,
            promotion_code: promo_code_id
          )

          payment_intent = retrieve_payment_intent(transaction[:latest_invoice]) if transaction[:status] == 'incomplete'
        else
          coupon_id = promo_code[:coupon][:id] if promo_code && promo_code[:coupon] && promo_code[:coupon][:id]
          invoice_item = ::Stripe::InvoiceItem.create(
            customer: customer[:id],
            price: params[:plan],
            discounts: [{ coupon: coupon_id }]
          )
          invoice = ::Stripe::Invoice.create(
            customer: customer[:id]
          )
          transaction = ::Stripe::Invoice.finalize_invoice(invoice[:id])
          payment_intent = retrieve_payment_intent(transaction[:id]) if transaction[:status] == 'open'
          transaction = ::Stripe::Invoice.pay(invoice[:id]) if payment_intent[:status] == 'successful'
        end

        finalize_transaction(transaction, plan) if transaction_ok(transaction)

        transaction = transaction.to_h.merge(transaction, payment_intent: payment_intent)

        render_json_dump transaction
      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
    end

    def finalize
      params.require([:plan, :transaction])
      begin
        price = ::Stripe::Price.retrieve(params[:plan])
        transaction = retrieve_transaction(params[:transaction])
        finalize_transaction(transaction, price) if transaction_ok(transaction)

        render_json_dump params[:transaction]
      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
    end

    def finalize_transaction(transaction, plan)
      group = plan_group(plan)

      group.add(current_user) if group

      customer = Customer.create(
        user_id: current_user.id,
        customer_id: transaction[:customer],
        product_id: plan[:product]
      )

      if transaction[:object] == 'subscription'
        Subscription.create(
          customer_id: customer.id,
          external_id: transaction[:id]
        )
      end
    end

    private

    def serialize_product(product)
      {
        id: product[:id],
        name: product[:name],
        description: PrettyText.cook(product[:metadata][:description]),
        subscribed: current_user_products.include?(product[:id])
      }
    end

    def current_user_products
      return [] if current_user.nil?

      Customer
        .select(:product_id)
        .where(user_id: current_user.id)
        .map { |c| c.product_id }.compact
    end

    def serialize_plans(plans)
      plans[:data].map do |plan|
        plan.to_h.slice(:id, :unit_amount, :currency, :type, :recurring)
      end.sort_by { |plan| plan[:amount] }
    end

    def create_customer(source)
      ::Stripe::Customer.create(
        email: current_user.email,
        source: source
      )
    end

    def retrieve_payment_intent(invoice_id)
      invoice = ::Stripe::Invoice.retrieve(invoice_id)
      ::Stripe::PaymentIntent.retrieve(invoice[:payment_intent])
    end

    def retrieve_transaction(transaction)
      begin
        case transaction
        when /^sub_/
          ::Stripe::Subscription.retrieve(transaction)
        when /^in_/
          ::Stripe::Invoice.retrieve(transaction)
        end
      rescue ::Stripe::InvalidRequestError => e
        e.message
      end
    end

    def metadata_user
      { user_id: current_user.id, username: current_user.username_lower }
    end

    def transaction_ok(transaction)
      %w[active trialing paid].include?(transaction[:status])
    end
  end
end
