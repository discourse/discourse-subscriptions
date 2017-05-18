# Discourse Donations

[![Build Status](https://travis-ci.org/choiceaustralia/discourse-donations.svg?branch=master)](https://travis-ci.org/choiceaustralia/discourse-donations)

Accept donations in Discourse! Integrates with [Stripe](https://stripe.com).

## Installation

* Be sure your site is enforcing https.
* Follow the install instructions here: https://meta.discourse.org/t/install-a-plugin/19157
* Add your Stripe public and private keys in settings and set the currency to your local value.
* Check that the custom header is enabled in admin > customize > themes.
* Enable the plugin and wait for people to donate money.

Note: There's an issue upgrading to 1.8.0.beta11 with themes. You might be required to disable the plugin to do upgrades.


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

* Donate when creating account
* Add a plugin outlet for custom user fields.
* Handle fails from stripe
