import { ajax } from "discourse/lib/ajax";

export default Ember.Controller.extend({
  init() {
    this._super(...arguments);
    this.set(
      "stripe",
      Stripe(Discourse.SiteSettings.discourse_subscriptions_public_key)
    );
    const elements = this.get("stripe").elements();

    this.set(
      "cardElement",
      elements.create("card", { hidePostalCode: true, disabled: true })
    );
  },

  actions: {
    stripePaymentHandler() {
      this.set("loading", true);

      this.stripe.createToken(this.get("cardElement")).then(result => {
        if (result.error) {
          bootbox.alert(result.error.message);
          this.set("loading", false);
        } else {
          const customerData = {
            source: result.token.id
          };

          return ajax("/s/customers", {
            method: "post",
            data: customerData
          }).then(customer => {
            const subscription = this.get("model.subscription");

            subscription.set("customer", customer.id);

            if (subscription.get("plan") === undefined) {
              subscription.set("plan", this.get("model.plans.firstObject.id"));
            }

            subscription
              .save()
              .then(() => {
                bootbox.alert(
                  I18n.t("discourse_subscriptions.transactions.payment.success")
                );
                this.transitionToRoute(
                  "user.subscriptions",
                  Discourse.User.current().username.toLowerCase()
                );
              })
              .finally(() => {
                this.set("loading", false);
              });
          });
        }
      });
    }
  }
});
