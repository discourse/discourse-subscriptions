import { action } from "@ember/object";
import Route from "@ember/routing/route";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";
import UserSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/user-subscription";

export default class UserBillingSubscriptionsIndexRoute extends Route {
  @service dialog;
  @service router;

  model() {
    // The model now returns a single, unified list from our refactored controller
    return UserSubscription.findAll().then(result => {
      // We still map to the Ember model to use its helpers, like `amountDollars`
      return result.map(sub => UserSubscription.create(sub));
    });
  }

  @action
  cancelSubscription(subscription) {
    this.dialog.yesNoConfirm({
      message: i18n("discourse_subscriptions.user.subscriptions.operations.destroy.confirm"),
      didConfirm: () => {
        subscription.set("loading", true);
        subscription.destroy()
          .then(() => this.refresh())
          .catch(popupAjaxError)
          .finally(() => subscription.set("loading", false));
      },
    });
  }
}
