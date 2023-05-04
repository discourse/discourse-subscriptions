import Controller from "@ember/controller";
import Subscription from "discourse/plugins/discourse-subscriptions/discourse/models/subscription";
import Transaction from "discourse/plugins/discourse-subscriptions/discourse/models/transaction";
import I18n from "I18n";
import { not } from "@ember/object/computed";
import discourseComputed from "discourse-common/utils/decorators";
import { inject as service } from "@ember/service";

export default Controller.extend({
  dialog: service(),
  selectedPlan: null,
  promoCode: null,
  cardholderAddress: {
    line1: null,
    city: null,
    state: null,
    country: null,
    postalCode: null,
  },
  isAnonymous: not("currentUser"),
  isCountryUS: false,

  init() {
    this._super(...arguments);
    this.set(
      "stripe",
      Stripe(this.siteSettings.discourse_subscriptions_public_key)
    );
    const elements = this.get("stripe").elements();

    this.set("cardElement", elements.create("card", { hidePostalCode: true }));

    this.set("isCountryUS", this.cardholderAddress.country === "US");
  },

  alert(path) {
    this.dialog.alert(I18n.t(`discourse_subscriptions.${path}`));
  },

  @discourseComputed("model.product.repurchaseable", "model.product.subscribed")
  canPurchase(repurchaseable, subscribed) {
    if (!repurchaseable && subscribed) {
      return false;
    }

    return true;
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
          cardholderAddress: this.cardholderAddress,
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
          this.dialog.alert(result.error.message || result.error);
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
      this.currentUser.username.toLowerCase()
    );
  },

  actions: {
    changeCountry(country) {
      this.set("cardholderAddress.country", country);
      this.set("isCountryUS", country === "US");
    },

    changeState(state) {
      this.set("cardholderAddress.state", state);
    },

    stripePaymentHandler() {
      this.set("loading", true);
      const plan = this.get("model.plans")
        .filterBy("id", this.selectedPlan)
        .get("firstObject");
      const cardholderAddress = this.cardholderAddress;

      if (!plan) {
        this.alert("plans.validate.payment_options.required");
        this.set("loading", false);
        return;
      }

      if (
        !Object.values(cardholderAddress).every(
          (fieldValue) => fieldValue !== null && fieldValue.length > 1
        )
      ) {
        this.alert("subscribe.invalid_cardholder_address");
        this.set("loading", false);
        return;
      }

      let transaction = this.createSubscription(plan);

      transaction
        .then((result) => {
          if (result.error) {
            this.dialog.alert(result.error.message || result.error);
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
          this.dialog.alert(
            result.jqXHR.responseJSON.errors[0] || result.errorThrown
          );
          this.set("loading", false);
        });
    },
  },
});
