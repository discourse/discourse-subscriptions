# frozen_string_literal: true

module DiscourseSubscriptions
  module User
    class PaymentsController < ::ApplicationController
      include DiscourseSubscriptions::Stripe
      before_action :set_api_key
      requires_login

      def index
        begin
          customer = Customer.find_by(user_id: current_user.id)
          product_ids = Product.all.pluck(:external_id)

          data = []

          if customer.present? && product_ids.present?
            # lots of matching because the Stripe API doesn't make it easy to match products => payments except from invoices
            all_invoices = ::Stripe::Invoice.list(customer: customer[:customer_id])
            invoices_with_products = all_invoices[:data].select { |invoice| product_ids.include?(invoice.dig(:lines, :data, 0, :plan, :product)) }
            invoice_ids = invoices_with_products.map { |invoice| invoice[:id] }
            payments = ::Stripe::PaymentIntent.list(customer: customer[:customer_id])
            payments_from_invoices = payments[:data].select { |payment| invoice_ids.include?(payment[:invoice]) }
            data = payments_from_invoices
          end

          render_json_dump data

        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end
    end
  end
end
