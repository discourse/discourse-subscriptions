import { ajax } from "discourse/lib/ajax";
import DiscourseURL from "discourse/lib/url";
import Plan from "discourse/plugins/discourse-patrons/discourse/models/plan";

export default Ember.Controller.extend({
  actions: {
    destroyPlan(plan) {
      plan.destroy().then(() =>
        this.controllerFor("adminBackupsIndex")
          .get("model")
          .removeObject(backup)
      );
    },

    editPlan(id) {
      return DiscourseURL.redirectTo(
        `/admin/plugins/discourse-patrons/plans/${id}`
      );
    }
  }
});
