import DiscourseURL from "discourse/lib/url";

export default Ember.Controller.extend({
  actions: {
    destroyPlan(plan) {
      plan.destroy().then(() =>
        this.controllerFor("adminPluginsDiscoursePatronsPlansIndex")
          .get("model")
          .removeObject(plan)
      );
    },

    editPlan(id) {
      return DiscourseURL.redirectTo(
        `/admin/plugins/discourse-patrons/plans/${id}`
      );
    }
  }
});
