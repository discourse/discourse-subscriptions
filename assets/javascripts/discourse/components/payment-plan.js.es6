import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  @discourseComputed("selectedPlan")
  selected(planId) {
    return planId === this.plan.id;
  },

  @discourseComputed("plan.type")
  recurringPlan(type) {
    return type === "recurring" ? true : false;
  },

  actions: {
    planClick() {
      this.clickPlan(this.plan);
      return false;
    }
  }
});
