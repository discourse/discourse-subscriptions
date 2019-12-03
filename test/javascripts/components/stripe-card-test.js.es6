import componentTest from "helpers/component-test";
import { stubStripe } from "discourse/plugins/discourse-subscriptions/helpers/stripe";

moduleForComponent("stripe-card", { integration: true });

componentTest("Discourse Patrons stripe card success", {
  template: `{{stripe-card handleConfirmStripeCard=onSubmit billing=billing}}`,

  beforeEach() {
    stubStripe();

    this.set(
      "billing",
      Ember.Object.create({
        name: "",
        email: "",
        phone: ""
      })
    );
  },

  async test(assert) {
    assert.expect(1);

    this.set("onSubmit", () => {
      assert.ok(true, "payment method created");
    });

    await click(".btn-payment");
  }
});
