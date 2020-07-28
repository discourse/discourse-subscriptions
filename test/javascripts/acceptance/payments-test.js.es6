import { acceptance } from "helpers/qunit-helpers";
import { stubStripe } from "discourse/plugins/discourse-subscriptions/helpers/stripe";

acceptance("Discourse Subscriptions", {
  beforeEach() {
    stubStripe();
  },

  loggedIn: true
});

QUnit.test("viewing product page", async assert => {
  await visit("/s");

  assert.ok($(".product-list").length, "has product page");
  assert.ok($(".product:first-child a").length, "has a link");
});
