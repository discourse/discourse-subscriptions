# frozen_string_literal: true

Fabricator(:stripe_charge, from: "DiscourseDonations::StripeResponse") do
  response = {
    "id": "ch_1FBxEe2eZvKYlo2CAWyww6QM",
    "object": "charge",
    "amount": 100,
    "amount_refunded": 0,
    "application": "null",
    "application_fee": "null",
    "application_fee_amount": "null",
    "balance_transaction": "txn_19XJJ02eZvKYlo2ClwuJ1rbA",
    "billing_details": {
      "address": {
        "city": "null",
        "country": "null",
        "line1": "null",
        "line2": "null",
        "postal_code": "null",
        "state": "null"
      },
      "email": "null",
      "name": "null",
      "phone": "null"
    },
    "captured": false,
    "created": 1566883732,
    "currency": "usd",
    "customer": "null",
    "description": "My First Test Charge (created for API docs)",
    "destination": "null",
    "dispute": "null",
    "failure_code": "null",
    "failure_message": "null",
    "fraud_details": {},
    "invoice": "null",
    "livemode": false,
    "metadata": {},
    "on_behalf_of": "null",
    "order": "null",
    "outcome": "null",
    "paid": true,
    "payment_intent": "null",
    "payment_method": "card_103Z0w2eZvKYlo2CyzMjT1R1",
    "payment_method_details": {
      "card": {
        "brand": "visa",
        "checks": {
          "address_line1_check": "null",
          "address_postal_code_check": "null",
          "cvc_check": "unchecked"
        },
        "country": "US",
        "exp_month": 2,
        "exp_year": 2015,
        "fingerprint": "Xt5EWLLDS7FJjR1c",
        "funding": "credit",
        "last4": "4242",
        "three_d_secure": "null",
        "wallet": "null"
      },
      "type": "card"
    },
    "receipt_email": "null",
    "receipt_number": "null",
    "receipt_url": "https://pay.stripe.com/receipts/acct_1032D82eZvKYlo2C/ch_1FBxEe2eZvKYlo2CAWyww6QM/rcpt_FhLw6tME6cvwGXWoL0Hn3f65Gkvyocg",
    "refunded": false,
    "refunds": {
      "object": "list",
      "data": [],
      "has_more": false,
      "total_count": 0,
      "url": "/v1/charges/ch_1FBxEe2eZvKYlo2CAWyww6QM/refunds"
    },
    "review": "null",
    "shipping": "null",
    "source": {
      "id": "card_103Z0w2eZvKYlo2CyzMjT1R1",
      "object": "card",
      "address_city": "null",
      "address_country": "null",
      "address_line1": "null",
      "address_line1_check": "null",
      "address_line2": "null",
      "address_state": "null",
      "address_zip": "null",
      "address_zip_check": "null",
      "brand": "Visa",
      "country": "US",
      "customer": "null",
      "cvc_check": "unchecked",
      "dynamic_last4": "null",
      "exp_month": 2,
      "exp_year": 2015,
      "fingerprint": "Xt5EWLLDS7FJjR1c",
      "funding": "credit",
      "last4": "4242",
      "metadata": {},
      "name": "null",
      "tokenization_method": "null"
    },
    "source_transfer": "null",
    "statement_descriptor": "null",
    "statement_descriptor_suffix": "null",
    "status": "succeeded",
    "transfer_data": "null",
    "transfer_group": "null"
  }.to_json

  to_json response
end
