# Discourse Payments

[![Build Status](https://travis-ci.org/choiceaustralia/memberful-integration.svg?branch=master)](https://travis-ci.org/choiceaustralia/choice-discourse)

Enables stripe payments from discourse.

# Configuration

You can either set your environment vars in docker or save them in a yaml.

**In your app.yml**

```
STRIPE_SECRET_KEY: 'my_secret_key'
STRIPE_PUBLISHABLE_KEY: 'my_publishable_key'
```

# Testing

Run the local js acceptance tests here:

http://localhost:3000/qunit?module=Acceptance%3A%20Discourse%20Payments
