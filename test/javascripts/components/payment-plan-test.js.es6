import componentTest from "helpers/component-test";

moduleForComponent("payment-plan", { integration: true });

componentTest("Payment plan subscription button rendered", {
  template: `{{payment-plan
    plan=plan
    selectedPlan=selectedPlan
  }}`,

  beforeEach() {
    this.set("plan", {
      type: "recurring",
      currency: "aud",
      recurring: { interval: "year" },
      amountDollars: "44.99"
    });
  },

  async test(assert) {
    assert.equal(
      find(".btn-discourse-subscriptions-subscribe").length,
      1,
      "The payment button is shown"
    );

    assert.equal(
      find(".btn-discourse-subscriptions-subscribe:first-child .interval")
        .text()
        .trim(),
      "Yearly",
      "The plan interval is shown -- Yearly"
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

componentTest("Payment plan one-time-payment button rendered", {
  template: `{{payment-plan
    plan=plan
    selectedPlan=selectedPlan
  }}`,

  beforeEach() {
    this.set("plan", {
      type: "one_time",
      currency: "USD",
      amountDollars: "3.99"
    });
  },

  async test(assert) {
    assert.equal(
      find(".btn-discourse-subscriptions-subscribe:first-child .interval")
        .text()
        .trim(),
      "One-Time Payment",
      "Shown as one time payment"
    );
  }
});
