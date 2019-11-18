# Discourse Patrons

[![Build Status](https://travis-ci.org/rimian/discourse-patrons.svg?branch=master)](https://travis-ci.org/rimian/discourse-patrons)

Accept payments from visitors to your [Discourse](https://www.discourse.org/) application. Integrates with [Stripe](https://stripe.com).

This is a newer version of https://github.com/rimian/discourse-donations.

## Installation

* Be sure your site is enforcing https.
* Follow the install instructions here: https://meta.discourse.org/t/install-a-plugin/19157
* Add your Stripe public and private keys in settings and set the currency to your local value.

## What are Subscriptions?

There are two core components to make subscriptions work for your Discourse application. These are **Products** and **Plans**. 

A Product describes what the user gets when they subscribe. It has a name and description and is associated with a Discourse user group. 

A Plan is how you charge your users for the Product. Plans have rates, billing intervals and trial periods. A Product may have multiple Plans. For example: a yearly and a monthly Plan. You can't change plans much once they are created but you can archive them and create new ones.

Together, Products and Plans make up subscriptions. 

## How to set up your Discourse app for subscriptions.

### Set up your payment gateway.

Firstly, you'll need an account with the [Stripe](https://stripe.com) payment gateway. This is how you manage your transactions. 

When you get a moment, take a look at Stripe's documentation. But for now, you can set up an account in test mode and see how it all works without making any real transactions. Then, if you're happy with how everything works, you can start taking real transactions. See below for test credit card numbers.

### Set up your User Groups in Discourse

When a user successfully subscribes to your Discourse application, after their credit card transation has been processed, they are added to a User Group. By assigning user's to a User Group, you can manage what your user's have access to on your website. User groups are a core functionality of Discourse and this plugin does nothing with them except and and remove users from the group you accociated with your Plan.

## Enter your configuration details

## Testing

Test with these credit card numbers:

* 4111 1111 1111 1111

## Warranty

This software comes without warranties or conditions of any kind.

## Credits

Many thanks to Chris Beach and Angus McLeod who helped on the [previous version](https://github.com/chrisbeach/discourse-donations) of this plugin. Many thanks to the Discourse team who sponsored this plugin! You guys rock.

## Known issues

* CSS is mucked up in Safari and probably Firefox too.
* The phone number isn't sent to Stripe

## TODOs

* Confirm dialog CSS isn't the best.
* Check against other themes (works ok with light and dark)
* Validate the model properly. Not in the stripe component
* Show the transaction on the thank you page.
* Work out where to put the helper tests. Name collision!
