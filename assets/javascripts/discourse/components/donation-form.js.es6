import { default as computed } from "ember-addons/ember-computed-decorators";

export default Ember.Component.extend({
  @computed("confirmation.card.last4")
  last4() {
    return this.get("confirmation.card.last4");
  },

  init() {
    this._super(...arguments);

    const settings = Discourse.SiteSettings;
    const amounts = settings.discourse_patrons_amounts.split("|");

    this.setProperties({
      confirmation: false,
      currency: settings.discourse_donations_currency,
      amounts,
      amount: amounts[0]
    });
  },

  actions: {
    closeModal() {
      this.set("paymentError", false);
      this.set("confirmation", false);
    },

    handleConfirmStripeCard(paymentMethod, receiptEmail) {
      this.set("receiptEmail", receiptEmail);
      this.set("confirmation", paymentMethod);
    },

    confirmStripeCard() {
      const data = {
        payment_method_id: this.confirmation.id,
        amount: this.amount,
        receipt_email: this.receiptEmail
      };

      this.stripePaymentHandler(data).then(paymentIntent => {
        if (paymentIntent.error) {
          this.set("paymentError", paymentIntent.error);
        } else {
          this.paymentSuccessHandler(paymentIntent.id);
        }
      });
    }
  }
});
