require 'fakeweb'

#TODO register some fixtures

FakeWeb.register_uri(:post, 'https://api.stripe.com/v1/subscriptions',
  :body => '{
  "id": "sub_AiD01tPjRSDFYu",
  "object": "subscription",
  "application_fee_percent": null,
  "cancel_at_period_end": false,
  "canceled_at": null,
  "created": 1495582751,
  "current_period_end": 1503531551,
  "current_period_start": 1495582751,
  "customer": "cus_AiD0rheP5e5fWO",
  "discount": null,
  "ended_at": null,
  "items": {
    "object": "list",
    "data": [
      {
        "id": "si_1AMmapEfVxQsvRbHOwo0LqL7",
        "object": "subscription_item",
        "created": 1495582752,
        "plan": {
          "id": "membership",
          "object": "plan",
          "amount": 2500,
          "created": 1495503265,
          "currency": "aud",
          "interval": "month",
          "interval_count": 3,
          "livemode": false,
          "metadata": {
          },
          "name": "Membership",
          "statement_descriptor": null,
          "trial_period_days": null
        },
        "quantity": 1
      }
    ],
    "has_more": false,
    "total_count": 1,
    "url": "/v1/subscription_items?subscription=sub_AiD01tPjRFFBYu"
  },
  "livemode": false,
  "metadata": {
  },
  "plan": {
    "id": "membership",
    "object": "plan",
    "amount": 2500,
    "created": 1495503265,
    "currency": "aud",
    "interval": "month",
    "interval_count": 3,
    "livemode": false,
    "metadata": {
    },
    "name": "Membership",
    "statement_descriptor": null,
    "trial_period_days": null
  },
  "quantity": 1,
  "start": 1495582751,
  "status": "active",
  "tax_percent": null,
  "trial_end": null,
  "trial_start": null
}'
)

FakeWeb.register_uri(:post, 'https://api.stripe.com/v1/customers',
  :body => '{
  "id": "cus_AJqrL4OU1sffPl",
  "object": "customer",
  "account_balance": 0,
  "created": 1489965018,
  "currency": "aud",
  "default_source": "card_19zDADEfVxQsvRbHVooMYHqg",
  "delinquent": false,
  "description": null,
  "discount": null,
  "email": "jo@example.com",
  "livemode": false,
  "metadata": {
  },
  "shipping": null,
  "sources": {
  "object": "list",
  "data": [
  {
    "id": "card_19zDADEfVxQsvRbHVooMYHqg",
    "object": "card",
    "address_city": null,
    "address_country": null,
    "address_line1": null,
    "address_line1_check": null,
    "address_line2": null,
    "address_state": null,
    "address_zip": null,
    "address_zip_check": null,
    "brand": "MasterCard",
    "country": "US",
    "customer": "cus_AJqrL4OU1sffPl",
    "cvc_check": "pass",
    "dynamic_last4": null,
    "exp_month": 11,
    "exp_year": 2022,
    "funding": "credit",
    "last4": "4444",
    "metadata": {
    },
    "name": null,
    "tokenization_method": null
  }
  ],
  "has_more": false,
  "total_count": 1,
  "url": "/v1/customers/cus_AJqrL4OU1sffPl/sources"
  }
  }',
  :status => ['200', 'OK']
)

FakeWeb.register_uri(:post, 'https://api.stripe.com/v1/charges',
  :body => '{
  "id": "ch_19zDAFEfVxQsvRbHtAwsCvV0",
  "object": "charge",
  "amount": 100,
  "amount_refunded": 0,
  "application": null,
  "application_fee": null,
  "balance_transaction": "txn_19wkkaEfVxQsvRbH8rnq3SAK",
  "captured": true,
  "created": 1489965019,
  "currency": "aud",
  "customer": "cus_AJqrL4OU1sffPl",
  "description": "Donation",
  "destination": null,
  "dispute": null,
  "failure_code": null,
  "failure_message": null,
  "fraud_details": {
  },
  "invoice": null,
  "livemode": false,
  "metadata": {
  },
  "on_behalf_of": null,
  "order": null,
  "outcome": {
  "network_status": "approved_by_network",
  "reason": null,
  "risk_level": "normal",
  "seller_message": "Payment complete.",
  "type": "authorized"
  },
  "paid": true,
  "receipt_email": null,
  "receipt_number": null,
  "refunded": false,
  "refunds": {
  "object": "list",
  "data": [

  ],
  "has_more": false,
  "total_count": 0,
  "url": "/v1/charges/ch_19zDAFEfVxQsvRbHtAwsCvV0/refunds"
  },
  "review": null,
  "shipping": null,
  "source": {
  "id": "card_19zDADEfVxQsvRbHVooMYHqg",
  "object": "card",
  "address_city": null,
  "address_country": null,
  "address_line1": null,
  "address_line1_check": null,
  "address_line2": null,
  "address_state": null,
  "address_zip": null,
  "address_zip_check": null,
  "brand": "MasterCard",
  "country": "US",
  "customer": "cus_AJqrL4OU1sffPl",
  "cvc_check": "pass",
  "dynamic_last4": null,
  "exp_month": 11,
  "exp_year": 2022,
  "funding": "credit",
  "last4": "4444",
  "metadata": {
  },
  "name": null,
  "tokenization_method": null
  },
  "source_transfer": null,
  "statement_descriptor": null,
  "status": "succeeded",
  "transfer_group": null
  }',
  :status => ['200', 'OK']
)
