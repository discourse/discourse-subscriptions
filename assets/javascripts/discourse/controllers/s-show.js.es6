import Controller from "@ember/controller";
import Customer from "discourse/plugins/discourse-subscriptions/discourse/models/customer";
import Payment from "discourse/plugins/discourse-subscriptions/discourse/models/payment";
import Subscription from "discourse/plugins/discourse-subscriptions/discourse/models/subscription";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from "I18n";

export default Controller.extend({
  planTypeIsSelected: true,

  @discourseComputed("planTypeIsSelected")
  type(planTypeIsSelected) {
    return planTypeIsSelected ? "plans" : "payment";
  },

  @discourseComputed("type")
  buttonText(type) {
    return I18n.t(`discourse_subscriptions.${type}.payment_button`);
  },

  init() {
    this._super(...arguments);
    this.set(
      "paymentsAllowed",
      Discourse.SiteSettings.discourse_subscriptions_allow_payments
    );
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

  createPayment(plan) {
    return this.stripe
      .createPaymentMethod("card", this.get("cardElement"))
      .then(result => {
        const payment = Payment.create({
          payment_method: result.paymentMethod.id,
          amount: plan.get("amount"),
          currency: plan.get("currency")
        });

        return payment.save();
      });
  },

  createSubscription(plan) {
    return this.stripe.createToken(this.get("cardElement")).then(result => {
      if (result.error) {
        return result;
      } else {
        const customer = Customer.create({ source: result.token.id });

        return customer.save().then(c => {
          const subscription = Subscription.create({
            customer: c.id,
            plan: plan.get("id")
          });

          return subscription.save();
        });
      }
    });
  },

  actions: {
    stripePaymentHandler() {
      this.set("loading", true);
      const type = this.get("type");
      const plan = this.get("model.plans")
        .filterBy("selected")
        .get("firstObject");

      if (!plan) {
        this.alert(`${type}.validate.payment_options.required`);
        this.set("loading", false);
        return;
      }

      let transaction;

      if (this.planTypeIsSelected) {
        transaction = this.createSubscription(plan);
      } else {
        transaction = this.createPayment(plan);
      }

      transaction
        .then(result => {
          if (result.error) {
            bootbox.alert(result.error.message || result.error);
          } else {
            if (result.status === "incomplete") {
              this.alert(`${type}.incomplete`);
            } else {
              this.alert(`${type}.success`);
            }

            const success_route = this.planTypeIsSelected
              ? "user.billing.subscriptions"
              : "user.billing.payments";

            this.transitionToRoute(
              success_route,
              Discourse.User.current().username.toLowerCase()
            );
          }
        })
        .catch(result => {
          bootbox.alert(result.errorThrown);
        })
        .finally(() => {
          this.set("loading", false);
        });
    }
  }
});
