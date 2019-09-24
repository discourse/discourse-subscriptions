export default Ember.Controller.extend({
  actions: {
    createPlan() {
      this.get("model")
        .save()
        .then(() => {
          this.transitionToRoute("adminPlugins.discourse-patrons.plans");
        });
    }
  }
});
