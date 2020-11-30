import EmberObject from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";
import { computed } from "@ember/object";

const Plan = EmberObject.extend({
  amountDollars: computed("unit_amount", {
    get() {
      return parseFloat(this.get("unit_amount") / 100).toFixed(2);
    },
    set(key, value) {
      const decimal = parseFloat(value) * 100;
      this.set("unit_amount", decimal);
      return value;
    },
  }),
  @discourseComputed("recurring.interval")
  billingInterval(interval) {
    return interval || "one-time";
  },

  @discourseComputed("amountDollars", "currency", "billingInterval")
  subscriptionRate(amountDollars, currency, interval) {
    return `${amountDollars} ${currency.toUpperCase()} / ${interval}`;
  },
});

export default Plan;
