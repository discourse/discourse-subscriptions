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
      bootbox.alert("ok payment good... some kind of message");
      this.transitionToRoute("user.billing", Discourse.User.current().username.toLowerCase());
    }
  }
});
