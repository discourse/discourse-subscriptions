import componentTest from "helpers/component-test";

moduleForComponent("donation-form", { integration: true });

componentTest("Discourse Patrons donation form has content", {
  template: `{{donation-form}}`,

  beforeEach() {
    this.registry.register(
      "component:stripe-card",
      Ember.Component.extend({ tagName: "dummy-component-tag" })
    );
    Discourse.SiteSettings.discourse_patrons_amounts = "1.00|2.01";
  },

  async test(assert) {
    assert.ok(
      find(".discourse-patrons-section-columns").length,
      "The card section renders"
    );
    assert.ok(
      find("dummy-component-tag").length,
      "The stripe component renders"
    );
  }
});

componentTest("donation form has a confirmation", {
  template: `{{donation-form confirmation=confirmation}}`,

  beforeEach() {
    this.registry.register("component:stripe-card", Ember.Component.extend());
    Discourse.SiteSettings.discourse_patrons_amounts = "1.00|2.01";
  },

  async skip(assert) {
    this.set("confirmation", { card: { last4: "4242" } });

    const confirmExists = find(".discourse-patrons-confirmation").length;

    assert.ok(confirmExists, "The confirmation form renders");

    const last4 = find(".discourse-patrons-last4")
      .text()
      .trim();

    assert.equal(last4, ".... .... .... 4242", "The last 4 digits are correct");
  }
});
