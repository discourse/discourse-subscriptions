import DiscourseURL from "discourse/lib/url";
import { ajax } from "discourse/lib/ajax";
import Subscription from "discourse/plugins/discourse-patrons/discourse/models/subscription";

export default Ember.Controller.extend({
  init() {
    this._super(...arguments);
    this.set(
      "stripe",
      Stripe(Discourse.SiteSettings.discourse_patrons_public_key)
    );
    const elements = this.get("stripe").elements();
    this.set("cardElement", elements.create("card", { hidePostalCode: true }));
  },

  actions: {
    stripePaymentHandler() {
      // https://stripe.com/docs/billing/subscriptions/payment#signup-flow

      this.stripe.createToken(this.get("cardElement")).then(result => {
        if (result.error) {
          // Inform the customer that there was an error.
          // var errorElement = document.getElementById('card-errors');
          // errorElement.textContent = result.error.message;
        } else {
          const customerData = {
            source: result.token.id
          };

          return ajax("/patrons/customers", {
            method: "post",
            data: customerData
          }).then(customer => {
            const subscription = this.get("model.subscription");

            subscription.set('customer', customer.id);

            if (subscription.get("plan") === undefined) {
              subscription.set("plan", this.get("model.plans.firstObject.id"));
            }

            subscription.save().then(() => {
              console.log('ok');
              // return DiscourseURL.redirectTo(
              //   Discourse.SiteSettings
              //     .discourse_patrons_subscription_group_landing_page
              // );
            });
          });
        }
      });
    }
  }
});
