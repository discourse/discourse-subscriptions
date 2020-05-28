import { equal } from "@ember/object/computed";
import Component from "@ember/component";

export default Component.extend({
  planButtonSelected: equal("planTypeIsSelected", true),
  paymentButtonSelected: equal("planTypeIsSelected", false),

  actions: {
    selectPlans() {
      this.set("planTypeIsSelected", true);
    },

    selectPayments() {
      this.set("planTypeIsSelected", false);
    },

    clickPlan(plan) {
      this.plans.map(p => p.set("selected", false));
      plan.set("selected", true);
    }
  }
});
