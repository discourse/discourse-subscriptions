import Route from "@ember/routing/route";
import AdminSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/admin-subscription";
import User from "discourse/models/user";

export default class AdminPluginsDiscourseSubscriptionsSubscriptionsRoute extends Route {
  // FIX: This tells Ember that the 'username' URL parameter is tied to this route
  queryParams = {
    username: {
      refreshModel: true // This re-runs the model() hook whenever the username changes
    }
  };

  model(params) {
    // FIX: Pass the search parameters to our find method
    return AdminSubscription.find({ offset: 0, username: params.username });
  }

  setupController(controller, model) {
    super.setupController(controller, model);

    if (model.unconfigured) {
      controller.set("subscriptions", []);
      controller.set("unconfigured", true);
      return;
    }

    const subscriptions = (model.subscriptions || []).map(s => {
      if (s.user) {
        s.user = User.create(s.user);
      }
      return AdminSubscription.create(s);
    });

    controller.set("subscriptions", subscriptions);
    controller.set("meta", model.meta);
    controller.set("username", model.meta.username);
  }
}
