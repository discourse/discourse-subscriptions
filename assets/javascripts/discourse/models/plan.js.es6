import EmberObject from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";

const Plan = EmberObject.extend({
  amountDollars: Ember.computed("unit_amount", {
    get() {
      return parseFloat(this.get("unit_amount") / 100).toFixed(2);
    },
    set(key, value) {
      const decimal = parseFloat(value) * 100;
      this.set("unit_amount", decimal);
      return value;
    }
  }),
  @discourseComputed("recurring.interval")
  billingInterval(interval) {
    return interval || "one-time";
  },

  @discourseComputed("amountDollars", "currency", "billingInterval")
  subscriptionRate(amountDollars, currency, interval) {
    return `${amountDollars} ${currency.toUpperCase()} / ${interval}`;
  },
  
  @discourseComputed("trial_period_days", "metadata")
  trialPeriodDays(trialAttr, metadata) {
    if (trialAttr) return trialAttr;
    else if (metadata.trial_period_days) return metadata.trial_period_days;
    else return null;
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
