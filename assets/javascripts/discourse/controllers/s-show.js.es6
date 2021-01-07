import Controller from "@ember/controller";
import Subscription from "discourse/plugins/discourse-subscriptions/discourse/models/subscription";
import Transaction from "discourse/plugins/discourse-subscriptions/discourse/models/transaction";
import I18n from "I18n";
import { not } from "@ember/object/computed";

export default Controller.extend({
  selectedPlan: null,
  promoCode: null,
  isAnonymous: not("currentUser"),

  init() {
    this._super(...arguments);
    this.set(
      "stripe",
      Stripe(Discourse.SiteSettings.discourse_subscriptions_public_key)
    );
    const elements = this.get("stripe").elements();

    this.set("cardElement", elements.create("card", { hidePostalCode: true }));
  },

  alert(path) {
    bootbox.alert(I18n.t(`discourse_subscriptions.${path}`));
  },

  createSubscription(plan) {
    return this.stripe.createToken(this.get("cardElement")).then((result) => {
      if (result.error) {
        this.set("loading", false);
        return result;
      } else {
        const subscription = Subscription.create({
          source: result.token.id,
          plan: plan.get("id"),
          promo: this.promoCode,
        });

        return subscription.save();
      }
    });
  },

  handleAuthentication(plan, transaction) {
    return this.stripe
      .confirmCardPayment(transaction.payment_intent.client_secret)
      .then((result) => {
        if (
          result.paymentIntent &&
          result.paymentIntent.status === "succeeded"
        ) {
          return result;
        } else {
          this.set("loading", false);
          bootbox.alert(result.error.message || result.error);
          return result;
        }
      });
  },

  _advanceSuccessfulTransaction(plan) {
    this.alert("plans.success");
    this.set("loading", false);

    this.transitionToRoute(
      plan.type === "recurring"
        ? "user.billing.subscriptions"
        : "user.billing.payments",
      Discourse.User.current().username.toLowerCase()
    );
  },

  actions: {
    stripePaymentHandler() {
      this.set("loading", true);
      const plan = this.get("model.plans")
        .filterBy("id", this.selectedPlan)
        .get("firstObject");

      if (!plan) {
        this.alert("plans.validate.payment_options.required");
        this.set("loading", false);
        return;
      }

      let transaction = this.createSubscription(plan);

      transaction
        .then((result) => {
          if (result.error) {
            bootbox.alert(result.error.message || result.error);
          } else if (
            result.status === "incomplete" ||
            result.status === "open"
          ) {
            const transactionId = result.id;
            const planId = this.selectedPlan;
            this.handleAuthentication(plan, result).then(
              (authenticationResult) => {
                if (authenticationResult && !authenticationResult.error) {
                  return Transaction.finalize(transactionId, planId).then(
                    () => {
                      this._advanceSuccessfulTransaction(plan);
                    }
                  );
                }
              }
            );
          } else {
            this._advanceSuccessfulTransaction(plan);
          }
        })
        .catch((result) => {
          bootbox.alert(result.errorThrown);
          this.set("loading", false);
        });
    },
  },
});
