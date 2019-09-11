import { ajax } from "discourse/lib/ajax";

export default Ember.Controller.extend({
  actions: {
    stripePaymentHandler(paymentMethodId, amount) {
      return ajax("/donate/charges", {
        data: { paymentMethodId, amount },
        method: "post"
      });
    },
  },
});
