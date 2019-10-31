import Plan from "discourse/plugins/discourse-patrons/discourse/models/plan";

QUnit.module("discourse-patrons:model:plan");

QUnit.test("subscriptionRate", assert => {
  const plan = Plan.create({
    amount: 2399,
    currency: 'aud',
    interval: 'month'
  });

  assert.equal(
    plan.get("subscriptionRate"),
    "$23.99 AUD / month",
    "it returns the formatted subscription rate"
  );
});

QUnit.test("amountDollars", assert => {
  const plan = Plan.create({ amount: 2399 });

  assert.equal(
    plan.get("amountDollars"),
    23.99,
    "it returns the formatted amount"
  );
});
