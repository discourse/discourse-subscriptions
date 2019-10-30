import computed from "ember-addons/ember-computed-decorators";
import { ajax } from "discourse/lib/ajax";

const Plan = Discourse.Model.extend({
  @computed("amount", "currency", "interval")
  subscriptionRate(amount, currency, interval) {
    const dollars = parseFloat(amount / 100).toFixed(2);
    return `$${dollars} ${currency.toUpperCase()} / ${interval}`;
  },
});

Plan.reopenClass({
  findAll() {
    return ajax("/patrons/plans", { method: "get" }).then(result =>
      result.map(plan => Plan.create(plan))
    );
  }
});

export default Plan;
