# frozen_string_literal: true

class PaymentSerializer < ApplicationSerializer
  attributes :payment_intent_id, :receipt_email, :url, :created_at_age, :amount, :amount_currency

  def created_at_age
    Time.now - object.created_at
  end

  def amount_currency
    ActiveSupport::NumberHelper.number_to_currency(
      object.amount/100,
      precision: 2,
      unit: currency_unit
    )
  end

  private

  def currency_unit
    case object.currency
    when "eur"
      "€"
    when "gbp"
      "£"
    else
      "$"
    end
  end
end
