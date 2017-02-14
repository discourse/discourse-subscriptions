# Discourse Payments

[![Build Status](https://travis-ci.org/choiceaustralia/discourse-payments.svg?branch=master)](https://travis-ci.org/choiceaustralia/discourse-payments)

Enables stripe payments from discourse.

# Configuration

You can either set your environment vars in docker or save them in a yaml.

**In your app.yml**

```
STRIPE_SECRET_KEY: 'my_secret_key'
STRIPE_PUBLISHABLE_KEY: 'my_publishable_key'
```

# Testing

To run the specs, install the plugin and run `bundle exec rake plugin:spec` in the discourse root directory.

Run the local js acceptance tests here:

http://localhost:3000/qunit?module=Acceptance%3A%20Discourse%20Payments
