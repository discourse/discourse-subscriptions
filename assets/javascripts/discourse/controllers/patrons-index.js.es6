import DiscourseURL from "discourse/lib/url";
import { ajax } from "discourse/lib/ajax";

export default Ember.Controller.extend({
  actions: {
    stripePaymentHandler(data) {
      return ajax("/patrons/patrons", {
        data,
        method: "post"
      }).catch(() => {
        return { error: "An error occured while submitting the form." };
      });
    },

    paymentSuccessHandler(paymentIntentId) {
      // DiscourseURL.redirectTo(`patrons/${paymentIntentId}`);
    }
  }
});
