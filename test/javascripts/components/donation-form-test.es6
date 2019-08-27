import componentTest from "helpers/component-test";

moduleForComponent("donation-form", { integration: true });

componentTest("donation form", {
  template: `{{donation-form}}`,

  test(assert) {
    assert.ok(true);
  }
});
