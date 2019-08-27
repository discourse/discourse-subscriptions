import componentTest from "helpers/component-test";

moduleForComponent("donation-form", { integration: true });

componentTest("donation form has content", {
  template: `{{donation-form}}`,

  async test(assert) {
    assert.ok(find('#payment-form').length, 'The form renders');
    assert.equal(find('.discourse-donations-cause .selected-name')
      .text()
      .trim(), 'Select a cause', 'It has the combo box');
  }
});
