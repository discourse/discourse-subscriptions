import Customer from "discourse/plugins/discourse-subscriptions/discourse/models/customer";
import Payment from "discourse/plugins/discourse-subscriptions/discourse/models/payment";
import Subscription from "discourse/plugins/discourse-subscriptions/discourse/models/subscription";
import computed from "discourse-common/utils/decorators";

export default Ember.Controller.extend({
  planTypeIsSelected: true,

  @computed("planTypeIsSelected")
  type(planTypeIsSelected) {
    return planTypeIsSelected ? "plans" : "payment";
  },

  @computed("type")
  buttonText(type) {
    return I18n.t(`discourse_subscriptions.${type}.payment_button`);
  },

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

  createSubsciption(plan) {
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
        transaction = this.createSubsciption(plan);
      } else {
        transaction = this.createPayment(plan);
      }

      transaction
        .then(result => {
          if (result.error) {
            bootbox.alert(result.error.message || result.error);
          } else {
            this.alert(`${type}.success`);

            const success_route = this.planTypeIsSelected
              ? "user.subscriptions"
              : "userActivity.payments";

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
