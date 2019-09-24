export default Ember.Controller.extend({
  actions: {
    createPlan() {
      this.transitionToRoute("adminPlugins.discourse-patrons.plans");
    }
  }
});
