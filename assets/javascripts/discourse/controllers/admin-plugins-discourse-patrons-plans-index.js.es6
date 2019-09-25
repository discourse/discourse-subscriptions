import { ajax } from "discourse/lib/ajax";

export default Ember.Controller.extend({
  actions: {
    deletePlan(id) {
      return ajax(`/patrons/admin/plans/${id}`, { method: "delete" });
    }
  }
});
