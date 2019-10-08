import { popupAjaxError } from "discourse/lib/ajax-error";

export default Ember.Controller.extend({
  actions: {
    createPlan() {
      this.get("model")
        .save()
        .then(() => {
          this.transitionToRoute("adminPlugins.discourse-patrons.plans");
        })
        .catch(popupAjaxError);
    }
  }
});
