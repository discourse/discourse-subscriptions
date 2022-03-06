import { acceptance, count } from "discourse/tests/helpers/qunit-helpers";
import { stubStripe } from "discourse/plugins/discourse-subscriptions/helpers/stripe";
import { click, visit } from "@ember/test-helpers";

acceptance("Discourse Subscriptions", function (needs) {
  needs.user();
  needs.hooks.beforeEach(function () {
    stubStripe();
  });

  test("subscribing", async function (assert) {
    await visit("/s");
    await click(".product:first-child a");

    assert.ok(
      count(".discourse-subscriptions-section-columns") > 0,
      "has the sections for billing"
    );

    assert.ok(
      count(".subscribe-buttons button") > 0,
      "has buttons for subscribe"
    );
  });
});
