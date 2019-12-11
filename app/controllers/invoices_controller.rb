# frozen_string_literal: true

module DiscourseSubscriptions
  class InvoicesController < ::ApplicationController
    include DiscourseSubscriptions::Stripe
    before_action :set_api_key
    requires_login

    def index
      begin
        customer = find_customer

        if viewing_own_invoices && customer.present?
          invoices = ::Stripe::Invoice.list(customer: customer.customer_id)

          render_json_dump invoices.data
        else
          render_json_dump []
        end
      rescue ::Stripe::InvalidRequestError => e
        render_json_error e.message
      end
    end

    private

    def viewing_own_invoices
      current_user.id == params[:user_id].to_i
    end

    def find_customer
      DiscourseSubscriptions::Customer.find_user(current_user)
    end
  end
end
