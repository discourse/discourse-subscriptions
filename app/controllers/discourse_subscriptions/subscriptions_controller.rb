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
        else
          invoice_item = ::Stripe::InvoiceItem.create(
            customer: params[:customer],
            price: params[:plan]
          )
          invoice = ::Stripe::Invoice.create(
            customer: params[:customer]
          )
          transaction = ::Stripe::Invoice.pay(invoice[:id])
        end

        if transaction_ok(transaction)
          group = plan_group(plan)

          group.add(current_user) if group

          customer = Customer.create(
            user_id: current_user.id,
            customer_id: params[:customer],
            product_id: plan[:product]
          )

          if transaction[:object] == 'subscription'
            Subscription.create(
              customer_id: customer.id,
              external_id: transaction[:id]
            )
          end
        end

        render_json_dump transaction
      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
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
