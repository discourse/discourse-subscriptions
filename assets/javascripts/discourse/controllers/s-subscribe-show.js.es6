import Customer from "discourse/plugins/discourse-subscriptions/discourse/models/customer";
import Subscription from "discourse/plugins/discourse-subscriptions/discourse/models/subscription";

export default Ember.Controller.extend({
  init() {
    this._super(...arguments);
    this.set(
      "stripe",
      Stripe(Discourse.SiteSettings.discourse_subscriptions_public_key)
    );
    const elements = this.get("stripe").elements();

    this.set("cardElement", elements.create("card", { hidePostalCode: true }));
  },

  actions: {
    stripePaymentHandler() {
      this.set("loading", true);
      const plan = this.get("model.plans")
        .filterBy("selected")
        .get("firstObject");

      if (!plan) {
        bootbox.alert(
          I18n.t(
            "discourse_subscriptions.transactions.payment.validate.plan.required"
          )
        );

        this.set("loading", false);
        return;
      }

      this.stripe.createToken(this.get("cardElement")).then(result => {
        if (result.error) {
          bootbox.alert(result.error.message);
          this.set("loading", false);
        } else {
          const customer = Customer.create({ source: result.token.id });

          customer.save().then(customer => {
            const subscription = Subscription.create({
              customer: customer.id,
              plan: plan.get("id")
            });

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
