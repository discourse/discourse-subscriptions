export default Ember.Component.extend({
  actions: {
    clickPlan(plan) {
      this.plans.map(p => p.set("selected", false));
      plan.set("selected", true);
    }
  }
});
