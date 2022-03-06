import { acceptance } from "discourse/tests/helpers/qunit-helpers";
import { stubStripe } from "discourse/plugins/discourse-subscriptions/helpers/stripe";
import { click, visit } from "@ember/test-helpers";

acceptance("Discourse Subscriptions", function (needs) {
  needs.user();
  needs.hooks.beforeEach(() => {
    stubStripe();
  });

  test("subscribing", async (assert) => {
    await visit("/s");

    await click(".product:first-child a");

    assert.ok(
      $(".discourse-subscriptions-section-columns").length,
      "has the sections for billing"
    );

    assert.ok(
      $(".subscribe-buttons button").length,
      "has buttons for subscribe"
    );
  });
});
