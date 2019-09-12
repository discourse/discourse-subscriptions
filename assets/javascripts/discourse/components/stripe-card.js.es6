export default Ember.Component.extend({
  init() {
    this._super(...arguments);

    const settings = Discourse.SiteSettings;

    this.setProperties({
      cardError: false,
      color: jQuery("body").css("color"),
      backgroundColor: jQuery("body").css("background-color"),
      stripe: Stripe(settings.discourse_patrons_public_key)
    });
  },

  didInsertElement() {
    this._super(...arguments);

    const color = this.get("color");

    const style = {
      base: {
        color,
        iconColor: color,
        "::placeholder": { color }
      }
    };

    const elements = this.stripe.elements();
    const card = elements.create("card", { style, hidePostalCode: true });

    card.mount("#card-element");

    this.set("card", card);

    card.on("change", result => {
      this.set("cardError", false);

      if (result.error) {
        this.set("cardError", result.error.message);
      }
    });
  },

  validateBilling() {
    const billing = this.get("billing");
    const deleteEmpty = key => {
      if (Ember.isEmpty(billing.get(key))) {
        billing.set(key, undefined);
      }
    };
    ["name", "phone", "email"].forEach(key => deleteEmpty(key));
  },

  actions: {
    submitStripeCard() {
      this.validateBilling();

      const paymentOptions = { billing_details: this.get("billing") };

      this.stripe.createPaymentMethod("card", this.card, paymentOptions).then(
        result => {
          if (result.error) {
            this.set("cardError", result.error.message);
          } else {
            this.handleConfirmStripeCard(result.paymentMethod);
          }
        },
        () => {
          this.set("cardError", "Unknown error.");
        }
      );
    }
  }
});
