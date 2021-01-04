import componentTest from "helpers/component-test";

moduleForComponent("payment-options", { integration: true });

componentTest("Discourse Subscriptions payment options have no plans", {
  template: `{{payment-options plans=plans}}`,

  async test(assert) {
    this.set("plans", false);

    assert.equal(
      find(".btn-discourse-subscriptions-subscribe").length,
      0,
      "The plan buttons are not shown"
    );
  },
});

componentTest("Discourse Subscriptions payment options has content", {
  template: `{{payment-options
      plans=plans
      selectedPlan=selectedPlan
    }}`,

  beforeEach() {
    this.set("plans", [
      {
        currency: "aud",
        recurring: { interval: "year" },
        amountDollars: "44.99",
      },
      {
        currency: "gdp",
        recurring: { interval: "month" },
        amountDollars: "9.99",
      },
    ]);
  },

  async test(assert) {
    assert.equal(this.selectedPlan, null, "No plans are selected by default");
  },
});
