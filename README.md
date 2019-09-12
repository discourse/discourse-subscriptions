# Discourse Patrons

[![Build Status](https://travis-ci.org/rimian/discourse-patrons.svg?branch=master)](https://travis-ci.org/rimian/discourse-patrons)

Accept payments from visitors to your [Discourse](https://www.discourse.org/) application. Integrates with [Stripe](https://stripe.com).

This is a newer version of https://github.com/rimian/discourse-donations.

## Installation

* Be sure your site is enforcing https.
* Follow the install instructions here: https://meta.discourse.org/t/install-a-plugin/19157
* Add your Stripe public and private keys in settings and set the currency to your local value.
* Enable the plugin and wait for people to donate money.

## Usage

Enable the plugin and enter your Stripe API keys in the settings. You can also configure amounts and the default currency.

Visit `/patrons`

## Testing

Test with these credit card numbers:

* 4111 1111 1111 1111

## Warranty

This software comes without warranties or conditions of any kind.

## Credits

Many thanks to Chris Beach and Angus McLeod who helped on the previous version of this plugin.

## Known issues

* CSS is mucked up in Safari and probably Firefox too.
* The phone number isn't sent to Stripe

## TODOs

* Add a description/message
* Check against other themes (works ok with light and dark)
* Validate the model properly. Not in the stripe component
* Show the transaction on the thank you page.
* Work out where to put the helper tests. Name collision!
