import { acceptance } from "helpers/qunit-helpers";
import { stubStripe } from "discourse/plugins/discourse-patrons/helpers/stripe";

acceptance("Discourse Patrons", {
  settings: {
    discourse_patrons_amounts: "1.00|2.00"
  },

  beforeEach() {
    stubStripe();
  }
});

QUnit.test("viewing", async assert => {
  await visit("/patrons");

  assert.ok($(".donations-page-payment").length, "has payment form class");
});
