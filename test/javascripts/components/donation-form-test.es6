import componentTest from "helpers/component-test";

moduleForComponent("donation-form", { integration: true });

componentTest("donation form has content", {
  template: `{{donation-form}}`,

  beforeEach() {
    this.registry.register('component:stripe-card', Ember.Component.extend({ tagName: 'dummy-component-tag' }));
  },

  async test(assert) {
    assert.ok(find('#payment-form').length, "The form renders");
    assert.ok(find('dummy-component-tag').length, "The stripe component renders");
  }
});
