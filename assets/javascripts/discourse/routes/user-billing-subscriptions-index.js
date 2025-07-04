import { action } from "@ember/object";
import Route from "@ember/routing/route";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";
import UserSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/user-subscription";

export default class UserBillingSubscriptionsIndexRoute extends Route {
  @service dialog;
  @service router;

  model() {
    // This now returns an object like { stripe: [...], razorpay: [...] }
    return UserSubscription.findAll();
  }

  setupController(controller, model) {
    super.setupController(...arguments);

    // We process the Stripe subscriptions with the existing model for formatting
    const stripeSubscriptions = (model.stripe || []).map(s => {
      s.plan = s.plan || {}; // Ensure plan object exists
      return UserSubscription.create(s);
    });

    controller.set('stripeSubscriptions', stripeSubscriptions);
    // We set the Razorpay purchases directly, as they are simple objects
    controller.set('razorpayPurchases', model.razorpay || []);
  }

  @action
  cancelSubscription(subscription) {
    this.dialog.yesNoConfirm({
      message: i18n("discourse_subscriptions.user.subscriptions.operations.destroy.confirm"),
      didConfirm: () => {
        subscription.set("loading", true);
        subscription
          .destroy()
          .then((result) => subscription.set("status", result.status))
          .catch((data) => this.dialog.alert(data.jqXHR.responseJSON.errors.join("\n")))
          .finally(() => {
            subscription.set("loading", false);
            this.refresh();
          });
      },
    });
  }
}
