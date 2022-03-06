import {
  count,
  discourseModule,
  query,
} from "discourse/tests/helpers/qunit-helpers";
import componentTest, {
  setupRenderingTest,
} from "discourse/tests/helpers/component-test";
import hbs from "htmlbars-inline-precompile";

discourseModule("payment-plan", function (hooks) {
  setupRenderingTest(hooks);

  componentTest("Payment plan subscription button rendered", {
    template: hbs`{{payment-plan
      plan=plan
      selectedPlan=selectedPlan
    }}`,

    beforeEach() {
      this.set("plan", {
        type: "recurring",
        currency: "aud",
        recurring: { interval: "year" },
        amountDollars: "44.99",
      });
    },

    async test(assert) {
      assert.strictEqual(
        count(".btn-discourse-subscriptions-subscribe"),
        1,
        "The payment button is shown"
      );

      assert.strictEqual(
        query(
          ".btn-discourse-subscriptions-subscribe:first-child .interval"
        ).innerText.trim(),
        "Yearly",
        "The plan interval is shown -- Yearly"
      );

      assert.strictEqual(
        query(
          ".btn-discourse-subscriptions-subscribe:first-child .amount"
        ).innerText.trim(),
        "$44.99",
        "The plan amount and currency is shown"
      );
    },
  });

  componentTest("Payment plan one-time-payment button rendered", {
    template: hbs`{{payment-plan
      plan=plan
      selectedPlan=selectedPlan
    }}`,

    beforeEach() {
      this.set("plan", {
        type: "one_time",
        currency: "USD",
        amountDollars: "3.99",
      });
    },

    async test(assert) {
      assert.strictEqual(
        query(
          ".btn-discourse-subscriptions-subscribe:first-child .interval"
        ).innerText.trim(),
        "One-Time Payment",
        "Shown as one time payment"
      );
    },
  });
});
