

class Customer
  attr_accessor :to_json
end

Fabricator(:customer) do
  response = {
    "id": "cus_FhHJDzf0OxYtb8",
    "object": "customer",
    "account_balance": 0,
    "address": "null",
    "balance": 0,
    "created": 1566866533,
    "currency": "usd",
    "default_source": "null",
    "delinquent": false,
    "description": "null",
    "discount": "null",
    "email": "null",
    "invoice_prefix": "0BBF354",
    "invoice_settings": {
      "custom_fields": "null",
      "default_payment_method": "null",
      "footer": "null"
    },
    "livemode": false,
    "metadata": {},
    "name": "null",
    "phone": "null",
    "preferred_locales": [],
    "shipping": "null",
    "sources": {
      "object": "list",
      "data": [],
      "has_more": false,
      "total_count": 0,
      "url": "/v1/customers/cus_FhHJDzf0OxYtb8/sources"
    },
    "subscriptions": {
      "object": "list",
      "data": [],
      "has_more": false,
      "total_count": 0,
      "url": "/v1/customers/cus_FhHJDzf0OxYtb8/subscriptions"
    },
    "tax_exempt": "none",
    "tax_ids": {
      "object": "list",
      "data": [],
      "has_more": false,
      "total_count": 0,
      "url": "/v1/customers/cus_FhHJDzf0OxYtb8/tax_ids"
    },
    "tax_info": "null",
    "tax_info_verification": "null"
  }.to_json

  to_json response
end
