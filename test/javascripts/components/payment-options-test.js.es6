import componentTest from "helpers/component-test";

moduleForComponent("payment-options", { integration: true });

componentTest("Discourse Subscriptions has no plans", {
  template: `{{payment-options plans=plans}}`,

  async test(assert) {
    this.set('plans', false);

    assert.equal(
      find("#subscribe-buttons .btn-discourse-subscriptions-subscribe").length,
      0,
      "The plan buttons are not shown"
    );
  }
});

componentTest("Discourse Subscriptions has content", {
  template: `{{payment-options plans=plans}}`,

  async test(assert) {
    this.set('plans', [1, 2]);

    assert.equal(
      find("#subscribe-buttons .btn-discourse-subscriptions-subscribe").length,
      2,
      "The plan buttons are shown"
    );
    assert.equal(
      find("#subscribe-buttons .btn-primary").length,
      0,
      "The none are selected"
    );
  }
});
