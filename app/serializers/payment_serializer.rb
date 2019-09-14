# frozen_string_literal: true

class PaymentSerializer < ApplicationSerializer
  attributes :payment_intent_id, :receipt_email, :url, :amount
end
