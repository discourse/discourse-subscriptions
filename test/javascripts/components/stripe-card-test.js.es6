import componentTest from "helpers/component-test";

moduleForComponent("stripe-card", { integration: true });

componentTest("Discourse Patrons stripe card success", {
  template: `{{stripe-card handleConfirmStripeCard=onSubmit}}`,

  beforeEach() {
    window.Stripe = () => {
      return {
        createPaymentMethod() {
          return new Ember.RSVP.Promise(resolve => {
            resolve({});
          });
        },
        elements() {
          return {
            create() {
              return {
                on() {},
                card() {},
                mount() {}
              };
            }
          };
        }
      };
    };
  },

  async test(assert) {
    assert.expect(1);

    this.set("onSubmit", () => {
      assert.ok(true, "payment method created");
    });

    await click(".btn-payment");
  }
});
