import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';
import { formatCurrency } from 'discourse/plugins/discourse-subscriptions/discourse/helpers/format-currency';

module('Unit | Helper | format-currency', function(hooks) {
  setupTest(hooks);

  test('it formats USD correctly', function(assert) {
    let result = formatCurrency(["USD", 338.2]);
    assert.equal(result, '$338.20', 'Formats USD correctly');
  });
});