import { acceptance } from "helpers/qunit-helpers";
acceptance("Discourse Patrons", { loggedIn: true });

test("the page loads", assert => {
  visit("/patrons");

  andThen(() => {
    assert.ok(true);
  });
});
