import Plan from "discourse/plugins/discourse-subscriptions/discourse/models/plan";

QUnit.module("discourse-patrons:model:plan");

QUnit.test("subscriptionRate", assert => {
  const plan = Plan.create({
    unit_amount: "2399",
    currency: "aud",
    recurring: {
      interval: "month"
    }
  });

  assert.equal(
    plan.get("subscriptionRate"),
    "23.99 AUD / month",
    "it returns the formatted subscription rate"
  );
});

QUnit.test("amountDollars", assert => {
  const plan = Plan.create({ unit_amount: 2399 });

  assert.equal(
    plan.get("amountDollars"),
    23.99,
    "it returns the formatted dollar amount"
  );
});

QUnit.test("amount", assert => {
  const plan = Plan.create({ amountDollars: "22.12" });

  assert.equal(plan.get("unit_amount"), 2212, "it returns the cents amount");
});
