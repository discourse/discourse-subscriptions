import Component from "@ember/component";

export default Component.extend({
  init() {
    this._super(...arguments);
    if (this.plans && this.plans.length === 1) {
      this.set("selectedPlan", this.plans[0].id);
    }
  },
  actions: {
    clickPlan(plan) {
      this.set("selectedPlan", plan.id);
    }
  }
});
