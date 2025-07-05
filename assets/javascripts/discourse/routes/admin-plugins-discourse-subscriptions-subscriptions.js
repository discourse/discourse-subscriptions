import Route from "@ember/routing/route";
import AdminSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/admin-subscription";
import User from "discourse/models/user";

export default class AdminPluginsDiscourseSubscriptionsSubscriptionsRoute extends Route {
  model() {
    return AdminSubscription.find();
  }

  setupController(controller, model) {
    super.setupController(...arguments);

    if (model.unconfigured) {
      controller.set('model', model); // Pass through the unconfigured state
      return;
    }

    // Process the Stripe list with the AdminSubscription model
    const stripeSubscriptions = (model.stripe || []).map(s => {
      // Create a user object so the template can display the avatar and link
      if (s.metadata) {
        s.user = User.create({ username: s.metadata.username, id: s.metadata.user_id });
      }
      return AdminSubscription.create(s);
    });
    controller.set('stripeSubscriptions', stripeSubscriptions);

    // Process the Razorpay list, creating User models for display
    const razorpayPurchases = (model.razorpay || []).map(p => {
      if (p.user) {
        p.user = User.create(p.user);
      }
      return p;
    });
    controller.set('razorpayPurchases', razorpayPurchases);
  }
}
