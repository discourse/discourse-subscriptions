import { acceptance, count } from "discourse/tests/helpers/qunit-helpers";
import { stubStripe } from "discourse/plugins/discourse-subscriptions/helpers/stripe";
import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import pretender, { response } from "discourse/tests/helpers/create-pretender";

function singleProductPretender() {
  pretender.get("/s", () => {
    const products = [
      {
        id: "prod_23o8I7tU4g56",
        name: "Awesome Product",
        description:
          "Subscribe to our awesome product. For only $230.10 per month, you can get access. This is a test site. No real credit card transactions.",
      },
    ];

    return response(products);
  });
}

acceptance("Discourse Subscriptions", function (needs) {
  needs.user();
  needs.hooks.beforeEach(function () {
    stubStripe();
  });

  test("subscribing", async function (assert) {
    await visit("/s");
    await click(".product:first-child a");

    assert.ok(
      count(".discourse-subscriptions-section-columns") > 0,
      "has the sections for billing"
    );

    assert.ok(
      count(".subscribe-buttons button") > 0,
      "has buttons for subscribe"
    );
  });

  test("skips products list on sites with one product", async function (assert) {
    singleProductPretender();

    await visit("/s");

    assert.dom(".subscribe-buttons button").exists({ count: 1 });
    assert.dom("input.subscribe-promo-code").exists();
    assert.dom("button.btn-payment").exists();
  });
});
