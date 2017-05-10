# Discourse Donations

[![Build Status](https://travis-ci.org/choiceaustralia/discourse-donations.svg?branch=master)](https://travis-ci.org/choiceaustralia/discourse-donations)

Accept donations in Discourse! Integrates with [Stripe](https://stripe.com).

Note: Stripe requires HTTPS.

## Creating new user accounts

This is an experimental feature. A user can create a new account if there is a donation.

## Installation

* Follow the install instructions here: https://meta.discourse.org/t/install-a-plugin/19157

## Configuration

Visit `/admin/plugins` and configure.

## Customisations

Visit `/admin/customize/site_texts` and search for 'discourse_donations'. You'll find a few entries you can customise for your site.

## Testing

* To run the rails specs, install the plugin and run `bundle exec rake plugin:spec[discourse-donations]` in the discourse root directory.
* To run qunit tests: `MODULE='Acceptance: Discourse Donations' bundle exec rake qunit:test[20000]`.
* To run Component tests: `MODULE='component:stripe-card' bundle exec rake qunit:test[20000]`.

**Note:**

* If you're using a zsh shell, then you probably get this error: `zsh: no matches found ...` and you'll need to escape the square brackets with backslashes.

## TODO

* Handle custom fields
* Handle fails from stripe
