import { default as computed } from "ember-addons/ember-computed-decorators";

export default Ember.Component.extend({
  @computed("confirmation.card.last4")
  last4() {
    return this.get("confirmation.card.last4");
  },

  init() {
    this._super(...arguments);

    const settings = Discourse.SiteSettings;

    this.setProperties({
      confirmation: false,
      currency: settings.discourse_donations_currency
    });
  },

  actions: {
    closeModal() {
      this.set("paymentError", false);
      this.set("confirmation", false);
    },

    handleConfirmStripeCard(paymentMethod) {
      this.set("confirmation", paymentMethod);
    },

    confirmStripeCard() {
      const paymentMethodId = this.confirmation.id;
      this.stripePaymentHandler(paymentMethodId, this.amount).then(
        paymentIntent => {
          if (paymentIntent.error) {
            this.set("paymentError", paymentIntent.error);
          } else {
            this.paymentSuccessHandler();
          }
        }
      );
    }
  }
});
