# frozen_string_literal: true

class PaymentSerializer < ApplicationSerializer
  attributes :payment_intent_id, :receipt_email, :url, :created_at_age, :amount

  def created_at_age
    Time.now - object.created_at
  end
end
