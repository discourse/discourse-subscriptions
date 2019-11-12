import { acceptance } from "helpers/qunit-helpers";

acceptance("Discourse Patrons", {
  settings: {
    discourse_patrons_subscription_group: "plan-id"
  },
  loggedIn: true
});

QUnit.test("subscribing", async assert => {
  await visit("/patrons/subscribe");

  assert.ok($("h3").length, "has a heading");
});
