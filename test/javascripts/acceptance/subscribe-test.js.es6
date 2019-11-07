import { acceptance } from "helpers/qunit-helpers";

acceptance("Discourse Patrons", {
  settings: {
    discourse_patrons_subscription_group: "plan-id"
  }
});

// TODO: add request fixtures

QUnit.skip("subscribing", async assert => {
  await visit("/patrons/subscribe");

  assert.ok($("h3").length, "has a heading");
});

QUnit.skip("subscribing with empty customer", async assert => {
  await visit("/patrons/subscribe");
  assert.ok(
    $(".discourse-patrons-subscribe-customer-empty").length,
    "has empty customer content"
  );
});
