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
        { params[:order] => ascending }
      else
        { created_at: :desc }
      end
    end

    def ascending
      if params[:descending] == 'false'
        :desc
      else
        :asc
      end
    end
  end
end
