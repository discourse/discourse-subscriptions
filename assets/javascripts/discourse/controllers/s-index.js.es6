import { ajax } from "discourse/lib/ajax";

export default Ember.Controller.extend({
  actions: {
    stripePaymentHandler(data) {
      return ajax("/s/patrons", {
        data,
        method: "post"
      }).catch(() => {
        return { error: "An error occured while submitting the form." };
      });
    },

    paymentSuccessHandler(/* paymentIntentId */) {
      bootbox.alert(I18n.t("discourse_subscriptions.transactions.payment.success"));
      this.transitionToRoute(
        "user.billing",
        Discourse.User.current().username.toLowerCase()
      );
    }
  }
});
