import Controller from "@ember/controller";
import DiscourseURL from "discourse/lib/url";

export default Controller.extend({
  actions: {
    editPlan(id) {
      return DiscourseURL.redirectTo(
        `/admin/plugins/discourse-subscriptions/plans/${id}`
      );
    }
  }
});
