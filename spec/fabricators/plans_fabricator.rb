# frozen_string_literal: true

Fabricator(:stripe_plans, from: "DiscourseDonations::StripeResponse") do
  response = {
  "object": "list",
  "url": "/v1/plans",
  "has_more": false,
  "data": [
      {
        "id": "plan_EeE4ns3bvb34ZP",
        "object": "plan",
        "active": true,
        "aggregate_usage": "null",
        "amount": 3000,
        "amount_decimal": "3000",
        "billing_scheme": "per_unit",
        "created": 1551862832,
        "currency": "usd",
        "interval": "month",
        "interval_count": 1,
        "livemode": false,
        "metadata": {},
        "nickname": "Pro Plan",
        "product": "prod_BT942zL7VcClrn",
        "tiers": "null",
        "tiers_mode": "null",
        "transform_usage": "null",
        "trial_period_days": "null",
        "usage_type": "licensed"
      },
    ]
  }.to_json

  to_json response
end
