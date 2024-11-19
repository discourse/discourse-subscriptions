import { action } from "@ember/object";
import Route from "@ember/routing/route";
import { service } from "@ember/service";
import I18n from "I18n";
import UserSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/user-subscription";

export default Route.extend({
  dialog: service(),
  router: service(),
  model() {
    return UserSubscription.findAll();
  },

  @action
  updateCard(subscriptionId) {
    this.router.transitionTo("user.billing.subscriptions.card", subscriptionId);
  },
  @action
  cancelSubscription(subscription) {
    this.dialog.yesNoConfirm({
      message: I18n.t(
        "discourse_subscriptions.user.subscriptions.operations.destroy.confirm"
      ),
      didConfirm: () => {
        subscription.set("loading", true);

        subscription
          .destroy()
          .then((result) => subscription.set("status", result.status))
          .catch((data) =>
            this.dialog.alert(data.jqXHR.responseJSON.errors.join("\n"))
          )
          .finally(() => {
            subscription.set("loading", false);
            this.refresh();
          });
      },
    });
  },
});
