import { acceptance } from "helpers/qunit-helpers";

acceptance("Discourse Subscriptions", {
  settings: {
    discourse_subscriptions_extra_nav_subscribe: true
  }
});

QUnit.test("plugin outlets", async assert => {
  await visit("/");

  assert.ok(
    $("#navigation-bar .discourse-patrons-subscribe").length,
    "has a subscribe button"
  );
});
