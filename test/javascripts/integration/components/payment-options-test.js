import hbs from "htmlbars-inline-precompile";
import componentTest, {
  setupRenderingTest,
} from "discourse/tests/helpers/component-test";
import { count, discourseModule } from "discourse/tests/helpers/qunit-helpers";

discourseModule("payment-options", function (hooks) {
  setupRenderingTest(hooks);

  componentTest("Discourse Subscriptions payment options have no plans", {
    template: hbs`{{payment-options plans=plans}}`,

    async test(assert) {
      this.set("plans", false);

      assert.strictEqual(
        count(".btn-discourse-subscriptions-subscribe"),
        0,
        "The plan buttons are not shown"
      );
    },
  });

  componentTest("Discourse Subscriptions payment options has content", {
    template: hbs`{{payment-options
      plans=plans
      selectedPlan=selectedPlan
    }}`,

    beforeEach() {
      this.set("plans", [
        {
          currency: "aud",
          recurring: { interval: "year" },
          amountDollars: "44.99",
        },
        {
          currency: "gdp",
          recurring: { interval: "month" },
          amountDollars: "9.99",
        },
      ]);
    },

    async test(assert) {
      assert.strictEqual(
        this.selectedPlan,
        undefined,
        "No plans are selected by default"
      );
    },
  });
});
