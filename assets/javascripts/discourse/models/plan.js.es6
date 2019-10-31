import computed from "ember-addons/ember-computed-decorators";
import { ajax } from "discourse/lib/ajax";

const Plan = Discourse.Model.extend({
  amountDollars: Ember.computed("amount", {
    get() {
      return parseFloat(this.get("amount") / 100).toFixed(2);
    },
    set(key, value) {
      const decimal = parseFloat(value) * 100;
      this.set("amount", decimal);
      return value;
    }
  }),

  @computed("amountDollars", "currency", "interval")
  subscriptionRate(amountDollars, currency, interval) {
    return `$${amountDollars} ${currency.toUpperCase()} / ${interval}`;
  }


});

Plan.reopenClass({
  findAll() {
    return ajax("/patrons/plans", { method: "get" }).then(result =>
      result.map(plan => Plan.create(plan))
    );
  }
});

export default Plan;
