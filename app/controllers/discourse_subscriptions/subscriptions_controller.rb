# frozen_string_literal: true

module DiscourseSubscriptions
  class SubscriptionsController < ::ApplicationController
    include DiscourseSubscriptions::Stripe
    include DiscourseSubscriptions::Group
    before_action :set_api_key
    requires_login

    def index
      begin
        products = ::Stripe::Product.list(active: true)

        subscriptions = products[:data].map do |p|
          {
            id: p[:id],
            description: p.dig(:metadata, :description)
          }
        end

        render_json_dump subscriptions
      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
    end

    def create
      begin
        plan = ::Stripe::Price.retrieve(params[:plan])
        
        recurring_plan = plan[:type] == 'recurring'

        if recurring_plan
          trial_days = plan[:metadata][:trial_period_days] if plan[:metadata] && plan[:metadata][:trial_period_days]

          transaction = ::Stripe::Subscription.create(
            customer: params[:customer],
            items: [{ price: params[:plan] }],
            metadata: metadata_user,
            trial_period_days: trial_days
          )

          payment_intent = retrieve_payment_intent(transaction[:latest_invoice]) if transaction[:status] == 'incomplete'
        else
          invoice_item = ::Stripe::InvoiceItem.create(
            customer: params[:customer],
            price: params[:plan]
          )
          invoice = ::Stripe::Invoice.create(
            customer: params[:customer]
          )
          transaction = ::Stripe::Invoice.pay(invoice[:id])
          payment_intent = retrieve_payment_intent(transaction[:id]) if transaction[:status] == 'incomplete'
        end

        finalize_transaction(transaction, plan) if transaction_ok(transaction)

        transaction = transaction.to_h.merge(transaction, payment_intent: payment_intent)

        render_json_dump transaction
      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
    end

    def finalize
      begin
        price = ::Stripe::Price.retrieve(params[:plan])
        transaction = retrieve_transaction(params[:transaction])
        finalize_transaction(transaction, price) if transaction_ok(transaction)

        render_json_dump params[:transaction]
      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
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

    def retrieve_payment_intent(invoice_id)
      invoice = ::Stripe::Invoice.retrieve(invoice_id)
      ::Stripe::PaymentIntent.retrieve(invoice[:payment_intent])
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

    def metadata_user
      { user_id: current_user.id, username: current_user.username_lower }
    end

    def transaction_ok(transaction)
      %w[active trialing paid].include?(transaction[:status])
    end
  end
end
