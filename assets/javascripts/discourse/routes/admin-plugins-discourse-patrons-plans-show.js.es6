import AdminPlan from "discourse/plugins/discourse-patrons/discourse/models/admin-plan";

export default Discourse.Route.extend({
  model() {
    return AdminPlan.create();
  }
});
