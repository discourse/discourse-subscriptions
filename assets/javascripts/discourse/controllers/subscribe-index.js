/* global Stripe, Razorpay */
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import Subscription from "discourse/plugins/discourse-subscriptions/discourse/models/subscription";
import { ajax } from "discourse/lib/ajax";
import { i18n } from "discourse-i18n";
import User from "discourse/models/user";

export default class SubscribeIndexController extends Controller {
  @service dialog;
  @service router;
  @service siteSettings;
  @service currentUser;

  @tracked productForCheckout = null;
  @tracked planForCheckout = null;
  @tracked loading = false;
  @tracked cardElement = null;

  @action
  startCheckout(product, plan) {
    this.productForCheckout = product;
    this.planForCheckout = plan;

    if (this.siteSettings.discourse_subscriptions_payment_provider === "Stripe") {
      const stripe = Stripe(this.siteSettings.discourse_subscriptions_public_key);
      const elements = stripe.elements();
      this.cardElement = elements.create("card", { hidePostalCode: true });
    }
  }

  @action
  cancelCheckout() {
    this.productForCheckout = null;
    this.planForCheckout = null;
    this.cardElement = null;
  }

  @action
  initiatePayment(paymentData) {
    this.loading = true;

    if (this.siteSettings.discourse_subscriptions_payment_provider === "Razorpay") {
      const subscription = Subscription.create({ plan: this.planForCheckout.id });
      subscription.save().then(result => this.processRazorpayPayment(result));
    } else { // Stripe
      const stripe = Stripe(this.siteSettings.discourse_subscriptions_public_key);
      stripe.createToken(this.cardElement, {
        name: paymentData.cardholderName,
      }).then(result => {
        if (result.error) {
          this.dialog.alert(result.error.message);
          this.loading = false;
        } else {
          const subscription = Subscription.create({
            source: result.token.id,
            plan: this.planForCheckout.id,
            promo: paymentData.promoCode,
            cardholderName: paymentData.cardholderName,
          });
          subscription.save()
            .then(transaction => this.handleStripeTransaction(transaction))
            .catch(err => this.dialog.alert(err.jqXHR.responseJSON.errors[0]));
        }
      });
    }
  }

  handleStripeTransaction(transaction) {
    if (transaction.status === "incomplete") {
      const stripe = Stripe(this.siteSettings.discourse_subscriptions_public_key);
      stripe.confirmCardPayment(transaction.payment_intent.client_secret)
        .then(result => {
          if (result.error) {
            this.dialog.alert(result.error.message);
            this.loading = false;
          } else {
            this._advanceSuccessfulTransaction();
          }
        });
    } else {
      this._advanceSuccessfulTransaction();
    }
  }

  processRazorpayPayment(order) {
    const options = {
      key: this.siteSettings.discourse_subscriptions_razorpay_key_id,
      amount: order.amount,
      currency: order.currency,
      name: this.productForCheckout.name,
      order_id: order.id,
      handler: (response) => {
        ajax("/s/finalize_razorpay_payment", { method: "post", data: { ...response, plan_id: this.planForCheckout.id } })
          .then(() => this._advanceSuccessfulTransaction())
          .catch(err => this.dialog.alert(err.jqXHR.responseJSON.errors[0]));
      },
      prefill: {
        name: this.currentUser.name || this.currentUser.username,
        email: this.currentUser.email,
      },
      theme: { color: "#3399cc" },
      modal: {
        ondismiss: () => { this.loading = false; }
      }
    };
    new Razorpay(options).open();
    this.loading = false;
  }

  _advanceSuccessfulTransaction() {
    this.dialog.alert(i18n("discourse_subscriptions.plans.success"));
    this.productForCheckout = null;
    this.planForCheckout = null;
    this.loading = false;
    this.router.transitionTo("user.billing.subscriptions", this.currentUser);
  }
}
