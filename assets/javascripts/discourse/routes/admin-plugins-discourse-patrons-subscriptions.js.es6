import AdminSubscription from "discourse/plugins/discourse-patrons/discourse/models/admin-subscription";

export default Discourse.Route.extend({
  model() {
    return AdminSubscription.find();
  }
});
