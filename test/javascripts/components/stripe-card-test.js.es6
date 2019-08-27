import componentTest from "helpers/component-test";

moduleForComponent("stripe-card", { integration: true });

window.Stripe = function() {
  return {
    elements: function() {
      return {
        create: function() {
          return {
            mount: function() {},
            card: function() {}
          };
        }
      };
    }
  };
};

componentTest("stripe card", {
  template: `{{stripe-card donateAmounts=donateAmounts}}`,

  skip: true,

  beforeEach() {
    Discourse.SiteSettings.discourse_donations_types = "";
    this.set("donateAmounts", [{ value: 2 }]);
  },

  test(assert) {
    assert.ok(true);
  }
});
