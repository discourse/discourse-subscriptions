import { acceptance } from "helpers/qunit-helpers";
import { stubStripe } from "discourse/plugins/discourse-subscriptions/helpers/stripe";

acceptance("Discourse Subscriptions", {
  beforeEach() {
    stubStripe();
  }
});

QUnit.test("viewing payment page", async assert => {
  await visit("/s");

  assert.ok($("#product-list").length, "has payment page");
});
