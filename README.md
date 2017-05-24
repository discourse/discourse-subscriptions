# Discourse Donations

[![Build Status](https://travis-ci.org/choiceaustralia/discourse-donations.svg?branch=master)](https://travis-ci.org/choiceaustralia/discourse-donations)

Accept donations in Discourse! Integrates with [Stripe](https://stripe.com).

## Installation

* Be sure your site is enforcing https.
* Follow the install instructions here: https://meta.discourse.org/t/install-a-plugin/19157
* Add your Stripe public and private keys in settings and set the currency to your local value.
* Add the following script to your page header in a custom theme component: `<script src="https://js.stripe.com/v3/"></script>`
* Enable the plugin and wait for people to donate money.

## Creating new user accounts

**This is an experimental feature.** A user can create a new account if they makes a successful donation. Enable this in settings. When a user is not logged in, they will be asked to enter details for a new user account. This feature doesn't support mandatory custom user fields yet.

## Testing

* To run the rails specs, install the plugin and run `bundle exec rake plugin:spec[discourse-donations]` in the discourse root directory.
* To run qunit tests: `MODULE='Acceptance: Discourse Donations' bundle exec rake qunit:test[20000]`.
* To run Component tests: `MODULE='component:stripe-card' bundle exec rake qunit:test[20000]`.

**Note:**

* If you're using a zsh shell, then you probably get this error: `zsh: no matches found ...` and you'll need to escape the square brackets with backslashes.

## TODO

* Handle custom fields
* Acceptance test in RSpec not qunit.

## Warranty

This software comes with no warranty of any kind.
