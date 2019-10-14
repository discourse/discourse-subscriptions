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
          const customerData = {
            source: result.token.id
          };

          return ajax("/patrons/customers", { method: "post", data: customerData }).then(
            customer => {
              // TODO move default plan into settings
              if(this.get('model.selectedPlan') == undefined) {
                this.set('model.selectedPlan', this.get('model.plans.firstObject'));
              }

              const subscriptionData = {
                customer: customer.id,
                plan: this.get('model.selectedPlan')
              };

              return ajax("/patrons/subscriptions", { method: "post", data: subscriptionData }).then(
                subscription => {
                  console.log(3, subscription);
                }
              );
            }
          );
        }
      });
    }
  }
});
