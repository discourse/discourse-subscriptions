# frozen_string_literal: true

module DiscourseSubscriptions
  module User
    class PaymentsController < ::ApplicationController
      include DiscourseSubscriptions::Stripe
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
              invoices_with_products = all_invoices[:data].select do |invoice|
                # i cannot dig it so we must get iffy with it
                if invoice[:lines] && invoice[:lines][:data] && invoice[:lines][:data][0] && invoice[:lines][:data][0][:plan] && invoice[:lines][:data][0][:plan][:product]
                  product_ids.include?(invoice[:lines][:data][0][:plan][:product])
                end
              end
              invoice_ids = invoices_with_products.map { |invoice| invoice[:id] }
              payments = ::Stripe::PaymentIntent.list(customer: customer_id)
              payments_from_invoices = payments[:data].select { |payment| invoice_ids.include?(payment[:invoice]) }
              data.concat(payments_from_invoices)
            end
          end

          data = data.sort_by { |pmt| pmt[:created] }.reverse

          render_json_dump data

        rescue ::Stripe::InvalidRequestError => e
          render_json_error e.message
        end
      end
    end
  end
end
