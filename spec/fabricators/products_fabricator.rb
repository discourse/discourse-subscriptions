# frozen_string_literal: true

Fabricator(:stripe_products, from: "DiscourseDonations::StripeResponse") do
  response = {
    "object": "list",
    "url": "/v1/products",
    "has_more": false,
    "data": [
      {
        "id": "prod_FhGJ7clA2xMxGI",
        "object": "product",
        "active": true,
        "attributes": [],
        "caption": "null",
        "created": 1566862775,
        "deactivate_on": [],
        "description": "null",
        "images": [],
        "livemode": false,
        "metadata": {},
        "name": "Sapphire Personal",
        "package_dimensions": "null",
        "shippable": "null",
        "statement_descriptor": "null",
        "type": "service",
        "unit_label": "null",
        "updated": 1566862775,
        "url": "null"
      },
    ]
  }.to_json

  to_json response
end
