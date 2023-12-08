import Route from "@ember/routing/route";
import AdminSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/admin-subscription";

export default Route.extend({
  model() {
    return AdminSubscription.find();
  },
});
