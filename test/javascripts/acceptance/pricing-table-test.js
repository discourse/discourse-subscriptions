import { acceptance } from "discourse/tests/helpers/qunit-helpers";
import { visit } from "@ember/test-helpers";
import { test } from "qunit";

acceptance("Discourse Subscriptions", function (needs) {
  needs.user();
  needs.settings({
    discourse_subscriptions_pricing_table: JSON.stringify({
      pricingTableId: "pricingTableId",
      publishableKey: "publishableKey",
    }),
  });

  test("pricing table element includes email", async function (assert) {
    await visit("/subscriptions");

    assert.equal(
      document.querySelector("stripe-pricing-table").outerHTML,
      `<stripe-pricing-table pricing-table-id="pricingTableId" publishable-key="publishableKey" customer-email="eviltrout@example.com"></stripe-pricing-table>`
    );
  });
});

acceptance("Discourse Subscriptions", function (needs) {
  needs.settings({
    discourse_subscriptions_pricing_table: JSON.stringify({
      pricingTableId: "pricingTableId",
      publishableKey: "publishableKey",
    }),
  });

  test("pricing table works for people without account", async function (assert) {
    await visit("/subscriptions");

    assert.equal(
      document.querySelector("stripe-pricing-table").outerHTML,
      `<stripe-pricing-table pricing-table-id="pricingTableId" publishable-key="publishableKey"></stripe-pricing-table>`
    );
  });
});

acceptance("Discourse Subscriptions", function (needs) {
  needs.user();

  test("pricing table element does not show up if not configured", async function (assert) {
    await visit("/subscriptions");

    assert.equal(document.querySelector("stripe-pricing-table"), null);
  });
});
