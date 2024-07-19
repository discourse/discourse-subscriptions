import { setupTest } from "ember-qunit";
import { module, test } from "qunit";
import { formatCurrency } from "discourse/plugins/discourse-subscriptions/discourse/helpers/format-currency";

module("Unit | Helper | format-currency", function (hooks) {
  setupTest(hooks);

  test("it formats USD correctly", function (assert) {
    let result = formatCurrency(["USD", 338.2]);
    assert.equal(result, "$338.20", "Formats USD correctly");
  });

  test("it rounds correctly", function (assert) {
    let result = formatCurrency(["USD", 338.289]);
    assert.equal(result, "$338.29", "Rounds correctly");
  });
});
