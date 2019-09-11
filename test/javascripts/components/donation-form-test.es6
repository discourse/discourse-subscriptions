import componentTest from "helpers/component-test";

moduleForComponent("donation-form", { integration: true });

componentTest("Discourse Patrons donation form has content", {
  template: `{{donation-form}}`,

  beforeEach() {
    this.registry.register(
      "component:stripe-card",
      Ember.Component.extend({ tagName: "dummy-component-tag" })
    );
  },

  async test(assert) {
    assert.ok(find(".discourse-patrons-section-columns").length, "The card section renders");
    assert.ok(
      find("dummy-component-tag").length,
      "The stripe component renders"
    );
  }
});

componentTest("donation form has a confirmation", {
  template: `{{donation-form confirmation=confirmation}}`,

  beforeEach() {
    this.registry.register(
      "component:stripe-card",
      Ember.Component.extend()
    );
  },

  async test(assert) {
    this.set("confirmation", { "card": { "last4": "4242" }});

    const confirmExists = find(".discourse-donations-confirmation").length;

    assert.ok(confirmExists, "The confirmation form renders");

    const last4 = find(".discourse-donations-last4").text().trim();

    assert.equal(last4, ".... .... .... 4242", "The last 4 digits are correct");
  }
});
