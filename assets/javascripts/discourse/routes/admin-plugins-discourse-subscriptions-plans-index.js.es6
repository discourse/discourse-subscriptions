import AdminPlan from "discourse/plugins/discourse-subscriptions/discourse/models/admin-plan";

export default Discourse.Route.extend({
  model() {
    return AdminPlan.findAll();
  }
});
