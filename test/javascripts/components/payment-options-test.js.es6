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
  }
});

componentTest("Discourse Subscriptions payment options has content", {
  template: `{{payment-options plans=plans}}`,

  async test(assert) {
    this.set("plans", [
      { currency: "aud", interval: "year", amountDollars: "44.99" },
      { currency: "gdp", interval: "month", amountDollars: "9.99" }
    ]);

    assert.equal(
      find(".btn-discourse-subscriptions-subscribe").length,
      2,
      "The plan buttons are shown"
    );
    assert.equal(
      find("#subscribe-buttons .btn-primary").length,
      0,
      "The none are selected"
    );
    assert.equal(
      find(".btn-discourse-subscriptions-subscribe:first-child .interval")
        .text()
        .trim(),
      "Yearly",
      "The plan interval is shown"
    );
    assert.equal(
      find(".btn-discourse-subscriptions-subscribe:first-child .amount")
        .text()
        .trim(),
      "$AUD 44.99",
      "The plan amount and currency is shown"
    );
  }
});

componentTest("Discourse Subscriptions payment options plan is selected", {
  template: `{{payment-options plans=plans selectPlan=selectPlan}}`,

  beforeEach() {},

  async test(assert) {
    assert.expect(1);
    this.set("plans", [
      { currency: "aud", interval: "year", amountDollars: "44.99" },
      { currency: "gdp", interval: "month", amountDollars: "9.99" }
    ]);

    this.set("selectPlan", function(plan) {
      assert.equal(plan, this.get('plans.firstObject'), "the plan is selected");
    });

    await click(".btn-discourse-subscriptions-subscribe:first-child");
  }
});
