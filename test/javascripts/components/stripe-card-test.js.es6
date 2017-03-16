import componentTest from 'helpers/component-test';

moduleForComponent('stripe-card', { integration: true });

window.Stripe = function() {
  return {
    elements: function() {
      return {
        create: function() {
          return {
            mount: function() {}
          };
        }
      };
    },
  };
};

componentTest('stripe card', {
  template: `{{stripe-card}}`,

  test(assert) {
    assert.ok(this.$('input[role=combobox]').length);
  }
});
