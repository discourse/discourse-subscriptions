import EmberObject from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";

const Plan = EmberObject.extend({
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

  @discourseComputed("amountDollars", "currency", "interval")
  subscriptionRate(amountDollars, currency, interval) {
    return `${amountDollars} ${currency.toUpperCase()} / ${interval}`;
  }
});

Plan.reopenClass({
  findAll(data) {
    return ajax("/s/plans", { method: "get", data }).then(result =>
      result.map(plan => Plan.create(plan))
    );
  }
});

export default Plan;
