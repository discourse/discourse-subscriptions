import { acceptance } from "helpers/qunit-helpers";

acceptance("Discourse Patrons");

QUnit.test("plugin outlets", async assert => {
  await visit("/");

  assert.ok(
    $("#navigation-bar .discourse-patrons-subscribe").length,
    "has a subscribe button"
  );
});
