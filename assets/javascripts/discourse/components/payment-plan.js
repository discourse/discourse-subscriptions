import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

const RECURRING = "recurring";

export default Component.extend({
  tagName: "",

  @discourseComputed("selectedPlan")
  selectedClass(planId) {
    return planId === this.plan.id ? "btn-primary" : "";
  },

  @discourseComputed("plan.type")
  recurringPlan(type) {
    return type === RECURRING;
  },

  actions: {
    planClick() {
      this.clickPlan(this.plan);
      return false;
    },
  },
});
