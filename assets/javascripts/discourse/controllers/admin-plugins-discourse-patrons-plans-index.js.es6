import { ajax } from "discourse/lib/ajax";
import computed from "ember-addons/ember-computed-decorators";

export default Ember.Controller.extend({
  @computed("model.plans")
  plans(plans) {
    return plans.filter(plan => !plan.deleted);
  },

  actions: {
    deletePlan(id) {
      return ajax(`/patrons/admin/plans/${id}`, { method: "delete" });
    }
  }
});
