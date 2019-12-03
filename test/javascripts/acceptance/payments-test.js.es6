import { acceptance } from "helpers/qunit-helpers";
import { stubStripe } from "discourse/plugins/discourse-subscriptions/helpers/stripe";

acceptance("Discourse Patrons", {
  settings: {
    discourse_patrons_amounts: "1.00|2.00"
  },

  beforeEach() {
    stubStripe();
  }
});

QUnit.skip("viewing the one-off payment page", async assert => {
  await visit("/s");

  assert.ok($(".donations-page-payment").length, "has payment form class");
});
