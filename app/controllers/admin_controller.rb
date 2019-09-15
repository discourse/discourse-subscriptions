# frozen_string_literal: true

module DiscoursePatrons
  class AdminController < ::Admin::AdminController
    def index
      payments = Payment.all.order(payments_order)

      render_serialized(payments, PaymentSerializer)
    end

    private

    def payments_order
      if %w(created_at amount).include?(params[:order])
        params[:order].to_sym
      else
        :created_at
      end
    end
  end
end
