import { ajax } from "discourse/lib/ajax";

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
          const data = {
            source: result.token.id
          };

          return ajax("/patrons/customers", { method: "post", data }).then(
            result => {
              // create subscription
            }
          );
        }
      });
    }
  }
});
