import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  @discourseComputed("plans")
  orderedPlans(plans) {
    if (plans) {
      return plans.sort((a, b) => (a.unit_amount > b.unit_amount ? 1 : -1));
    }
  },

  didInsertElement() {
    this._super(...arguments);
    if (this.plans && this.plans.length === 1) {
      this.set("selectedPlan", this.plans[0].id);
    }
  },
  actions: {
    clickPlan(plan) {
      this.set("selectedPlan", plan.id);
    },
  },
});
