import { acceptance } from "helpers/qunit-helpers";
import { stubStripe } from "discourse/plugins/discourse-subscriptions/helpers/stripe";

acceptance("Discourse Subscriptions", {
  beforeEach() {
    stubStripe();
  },

  loggedIn: true
});

QUnit.test("subscribing", async assert => {
  await visit("/s");

  await click(".product:first-child a");

  assert.ok(
    $(".discourse-subscriptions-section-columns").length,
    "has the sections for billing"
  );

  assert.ok($(".subscribe-buttons button").length, "has buttons for subscribe");
});
