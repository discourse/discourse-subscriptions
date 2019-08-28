import componentTest from "helpers/component-test";

moduleForComponent("donation-row", { integration: true });

componentTest("donation-row", {
  template: `{{donation-row currency=3 amount=21 period='monthly'}}`,

  test(assert) {
    assert.equal(find(".donation-row-currency").text(), "3", "It has currency");
    assert.equal(find(".donation-row-amount").text(), "21", "It has an amount");
    assert.equal(find(".donation-row-period").text(), "monthly", "It has a period");
  }
});

componentTest("donation-row cancels subscription", {
  template: `{{donation-row currentUser=currentUser subscription=subscription}}`,

  beforeEach() {
    this.set("currentUser", true);
    this.set("subscription", true);
  },

  async test(assert) {
    assert.ok(find(".donation-row-subscription").length, "It has a subscription");
  }
});
