# frozen_string_literal: true

module DiscourseSubscriptions
  module User
    class PaymentsController < ::ApplicationController
      include DiscourseSubscriptions::Stripe

      requires_plugin DiscourseSubscriptions::PLUGIN_NAME

      before_action :set_api_key
      requires_login

      def index
        begin
          customer = Customer.where(user_id: current_user.id)
          customer_ids = customer.map { |c| c.customer_id } if customer
          product_ids = Product.all.pluck(:external_id)

          data = []

          if customer_ids.present? && product_ids.present?
            customer_ids.each do |customer_id|
              # lots of matching because the Stripe API doesn't make it easy to match products => payments except from invoices
              all_invoices = ::Stripe::Invoice.list(customer: customer_id)
              invoices_with_products = parse_invoices(all_invoices, product_ids)
              invoice_ids = invoices_with_products.map { |invoice| invoice[:id] }
              payments = ::Stripe::PaymentIntent.list(customer: customer_id)
              payments_from_invoices =
                payments[:data].select { |payment| invoice_ids.include?(payment[:invoice]) }

              # Pricing table one-off purchases do not have invoices
              payments_without_invoices =
                payments[:data].select { |payment| payment[:invoice].nil? }

              data = data | payments_from_invoices | payments_without_invoices
            end
          end

          data = data.sort_by { |pmt| pmt[:created] }.reverse

          render_json_dump data
        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end

      private

      def parse_invoices(all_invoices, product_ids)
        all_invoices[:data].select do |invoice|
          invoice_lines = invoice[:lines][:data][0] if invoice[:lines] && invoice[:lines][:data]
          if invoice_lines
            invoice_product_id = parse_invoice_lines(invoice_lines)
            product_ids.include?(invoice_product_id)
          end
        end
      end

      def parse_invoice_lines(invoice_lines)
        invoice_product_id = invoice_lines[:price][:product] if invoice_lines[:price] &&
          invoice_lines[:price][:product]
        invoice_product_id = invoice_lines[:plan][:product] if invoice_lines[:plan] &&
          invoice_lines[:plan][:product]
        invoice_product_id
      end
    end
  end
end
