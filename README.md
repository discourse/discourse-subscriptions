# Discourse Subscriptions

The Discourse Subscriptions plugin allows you to set up a subscription based Discourse application. By integrating with the [Stripe](https://stripe.com) payment gateway and setting up this plugin to manage Subscriptions, you can start allowing users access to content on your website on a user pays basis.

You can test this plugin here: https://discourse.rimian.com.au/s. See testing section below for test credit card numbers.

### Features

Discourse Subscriptions supports the following features:

* A credit card payment page.
* A settings page to manage Stripe configuration.
* Administration to create, update and view *products*, *plans* and *subscriptions*.
* Setting the user group associated with the subscription.
* Cancelling a subscription from admin.
* Adds and removes users from user groups when subscriptions are created or deleted.
* Allows the user to cancel their subscription in their user profile.
* Webhooks that update your website when an event occurs on Stripe.

See screenshots below.

## Plugin Installation

Follow the [plugin](https://github.com/discourse/discourse-subscriptions/) install instructions here: https://meta.discourse.org/t/install-a-plugin/19157

## Core concepts

### Managing your Stripe Account

Ultimately, your Subscriptions are managed by the Stripe subscription portal. Stripe will handle the recurring billing, invoices, etc at the required intervals and notify your [Discourse Subscriptions](https://github.com/discourse/discourse-subscriptions/) plugin when specific transactions happen.

This plugin does not store Stripe transaction or subscription details in your database other than the customer and product identifiers associated with those transactions. User group management is not stored in the stripe Portal.

Be very careful to keep your Stripe private keys safe and secure at all times.

**It is important to note** that if you were to shut down your instance of Discourse, uninstall this plugin or your site were to go offline, Stripe will continue to bill your customers for your service. It is your responsibility to manage your customers and provide the service they are paying for.

Stripe has a [portal](https://dashboard.stripe.com) where you can manage all your customer's, payments and subscriptions.

### Subscriptions

Suscriptions are major feature of Stripe and this plugin's primary function is to leverage this feature by assigning Subscriptions to Discourse *user groups*. Subscriptions allow you to take payments and controll access to content on your website.

When a subscription is created or deleted, a user is added or removed from the user group you associate with your subscription. Please note: If you manually remove or add users to a user group via Discourse admin, you'll need to manage subscriptions for those users manually.

### Products

A Product describes what the user gets when they subscribe. It is basically a user group on your website. A product has a *name* and *description* and most importantly, it is associated with a Discourse User Group.

A product can have one or more *plans*.

### Plans

A Plan determines how and when you charge your users for the Product. Plans have *rates*, *billing intervals* and *trial periods*. A Product may have multiple Plans. For example: a yearly and a monthly Plan with different pricing. You can't change plans much once they are created but you can archive them and create new ones.

Together, Products and Plans make up Subscriptions.

## Getting started with Discourse Subscriptions

To begin, you can install this plugin and try it out in test mode. You can disable the navigation link in settings while you're testing.

### Set up your Payment Gateway.

Firstly, you'll need an account with the [Stripe](https://stripe.com) payment gateway. To get started, you can set up an account in test mode and see how it all works without making any real transactions or having to set up a bank account.

### Set up Webhooks and Events in your Stripe account

Once you have an account on Stripe, you'll need to [tell Stripe your website's address](https://dashboard.stripe.com/test/webhooks) so it can notify you about certain transactions. You can enter this in your Stripe dashboard under **Endpoints > URL**.

The address for webhooks is: `[your server address]/s/hooks` where [your server address] is the URL of your discourse install.

You'll also need to tell Stripe which events it should notify you about via the webhook URL. You can select specific events or all of them. By allowing all events to be sent to your server, you don't have to worry about which events are important to you, but it will significantly load up your server and could cause problems with your site's availability. If you're concerned about this, only add the events below under **Webhook details**.

Currently, Discourse Subscriptions responds to the following events:

* `customer.subscription.deleted`
* `customer.subscription.updated`

**Warning:** Events supported by this plugin may change, in the future as new features are added to this plugin.

### Add the Stripe API and Webhook keys to your plugin settings

Stripe needs to be authorised to communicate with your website. To do this, it publishes a pair of private and public *API keys* and a *signing secret* for your web hooks.

To authorise webhooks, add the API keys and webhook secret from Stripe to your settings page (under Developers).

In your Stripe account settings, see:
* https://dashboard.stripe.com/test/apikeys
* https://dashboard.stripe.com/test/webhooks

### Set up your User Groups in Discourse

When a user successfully subscribes to your Discourse application, after their credit card transaction has been processed, they are added to a User Group. By assigning users to a User Group, you can manage what your users have access to on your website. User groups are a core functionality of Discourse and this plugin does nothing with them except add and remove users from the group you associated with your Plan.

## Enter your configuration details

When you create an account with Stripe, you'll get a public and private key. These are entered in the Discourse Subscriptions admin so your subscriptions can integrate with Stripe. There are different keys for testing and production environments.

You can also toggle the Subscribe button on and off in case you want to hide the link while you're setting up.

## Create one or more products with plans.

In the admin, add a new Product. Once you have a product saved, you can add plans to it. Keep in mind that the pricing and billing intervals of plans cannot be changed once you create them. This is to avoid confusion around subscription management.

If you take a look at your [Stripe Dashboard](https://dashboard.stripe.com), you'll see all those products and plans are listed. Discourse Subscriptions does not create them locally. They are created in Stripe.

## Testing

Test with these credit card numbers:

* 4111 1111 1111 1111 (no authentication required)
* 4000 0027 6000 3184 (authentication required)

For more test card numbers: https://stripe.com/docs/testing

Visit `/s` and enter a few test transactions.

## Credits

Many thanks to [Rimian Perkins](https://github.com/rimian/) for his work on this plugin! Also thanks to Chris Beach and Angus McLeod who helped with the previous version of this plugin.
## Screenshots

### Products Admin
![Admin Products](https://raw.githubusercontent.com/rimian/discourse-subscriptions/master/doc/admin-products.png)
### Product Admin
![Admin Product](https://raw.githubusercontent.com/rimian/discourse-subscriptions/master/doc/admin-product.png)
### Plan Admin
![Admin Plan](https://raw.githubusercontent.com/rimian/discourse-subscriptions/master/doc/admin-plan.png)
### Subscription Admin
![Admin Subscriptions](https://raw.githubusercontent.com/rimian/discourse-subscriptions/master/doc/admin-subscriptions.png)
### Subscription User
![Admin Subscriptions](https://raw.githubusercontent.com/rimian/discourse-subscriptions/master/doc/user-subscriptions.png)
### Payments User
![Admin Subscriptions](https://raw.githubusercontent.com/rimian/discourse-subscriptions/master/doc/user-payments.png)
### Subscribe
![Admin Subscriptions](https://raw.githubusercontent.com/rimian/discourse-subscriptions/master/doc/subscribe.png)
### Settings
![Admin Settings](https://raw.githubusercontent.com/rimian/discourse-subscriptions/master/doc/settings.png)
