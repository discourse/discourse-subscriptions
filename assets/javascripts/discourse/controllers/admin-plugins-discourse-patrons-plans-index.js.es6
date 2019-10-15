import DiscourseURL from "discourse/lib/url";

export default Ember.Controller.extend({
  actions: {
    editPlan(id) {
      return DiscourseURL.redirectTo(
        `/admin/plugins/discourse-patrons/plans/${id}`
      );
    }
  }
});
