import Route from "@ember/routing/route";
import AdminSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/admin-subscription";
import User from "discourse/models/user";

export default class AdminPluginsDiscourseSubscriptionsSubscriptionsRoute extends Route {
  model() {
    // Fetch the initial page of data
    return AdminSubscription.find({ offset: 0 });
  }

  setupController(controller, model) {
    super.setupController(...arguments);

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
  }
}
