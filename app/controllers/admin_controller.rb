# frozen_string_literal: true

module DiscoursePatrons
  class AdminController < ::Admin::AdminController
    def index
      payments = Payment.all

      render_serialized(payments, PaymentSerializer)
    end
  end
end
