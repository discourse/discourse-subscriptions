import componentTest from 'helpers/component-test';

moduleForComponent('donation-row', { integration: true });

componentTest('donation-row', {
  template: `{{donation-row currency=3 amount=21 period='monthly'}}`,

  test(assert) {
    assert.equal(find('.donation-row-currency').text(), '3');
    assert.equal(find('.donation-row-amount').text(), '21');
    assert.equal(find('.donation-row-period').text(), 'monthly');
  },
});

componentTest('donation-row cancels subscription', {
  template: `{{donation-row currentUser=currentUser subscription=subscription}}`,

  beforeEach() {
    this.set('currentUser', true);
    this.set('subscription', true);
  },

  async test(assert) {
    assert.ok(find('.donation-row-subscription').length);
  },
});
