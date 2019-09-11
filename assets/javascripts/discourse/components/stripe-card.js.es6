
export default Ember.Component.extend({
  init() {
    this._super(...arguments);

    const settings = Discourse.SiteSettings;

    this.setProperties({
      cardError: false,
      color: jQuery("body").css("color"),
      backgroundColor: jQuery("body").css("background-color"),
      stripe: Stripe(settings.discourse_patrons_public_key),
    });
  },

  didInsertElement() {
    this._super(...arguments);

    const color = this.get('color');

    const style = {
      base: {
        color,
        iconColor: color,
        "::placeholder": { color }
      }
    };

    const elements = this.stripe.elements();
    const card = elements.create("card", { style, hidePostalCode: true });

    card.mount('#card-element');

    this.set("card", card);

    card.on("change", (result) => {
      this.set('cardError', false);

      if(result.error) {
        this.set('cardError', result.error.message);
      }
    });
  },

  actions: {
    submitStripeCard() {
      this.stripe.createPaymentMethod('card', this.card).then((result) => {
        if (result.error) {
          this.set('cardError', result.error.message);
        }
        else {
          this.handleConfirmStripeCard(result.paymentMethod);
        }
      }, () => {
        this.set('cardError', 'Unknown error.');
      });
    },
  },
});
