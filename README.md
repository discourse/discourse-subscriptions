# Discourse Donations

[![Build Status](https://travis-ci.org/choiceaustralia/discourse-donations.svg?branch=master)](https://travis-ci.org/choiceaustralia/discourse-donations)

Accept donations in Discourse! Integrates with [Stripe](https://stripe.com).

## Installation

* Follow the install instructions here: https://meta.discourse.org/t/install-a-plugin/19157
* Set the private and public keys in the plugin settings.

## Configuration

Visit `/admin/plugins` and configure your private and public keys.

## TODO

* Add a plugin outlet for custom user fields.
* Some tests
* Handle fails from stripe
* A button in the user's profile page.

## Testing

* To run the rails specs, install the plugin and run `bundle exec rake plugin:spec[discourse-donations]` in the discourse root directory.
* To run qunit tests: `MODULE='Acceptance: Discourse Donations' bundle exec rake qunit:test[20000]`.
* To run Component tests: `MODULE='component:stripe-card' bundle exec rake qunit:test[20000]`.

**Note:**

* [This fix](https://github.com/discourse/discourse/pull/4719) is required to run qunit test modules.
* If you're using a zsh shell, then you probably get this error: `zsh: no matches found ...` and you'll need to escape the square brackets with backslashes.
* [This fix](https://github.com/discourse/discourse/pull/4738) renders the extra nav items consistently.
