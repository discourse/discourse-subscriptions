import Controller from "@ember/controller";
import Customer from "discourse/plugins/discourse-subscriptions/discourse/models/customer";
import Subscription from "discourse/plugins/discourse-subscriptions/discourse/models/subscription";
import I18n from "I18n";

export default Controller.extend({
  selectedPlan: null,

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
        .then(result => {
          if (result.error) {
            bootbox.alert(result.error.message || result.error);
          } else {
            if (result.status === "incomplete") {
              this.alert("plans.incomplete");
            } else {
              this.alert("plans.success");
            }

            let success_route;
            if (plan.type === "recurring") {
              success_route = "user.billing.subscriptions";
            } else {
              success_route = "user.billing.payments";
            }

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
