import Route from "@ember/routing/route";
import UserSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/user-subscription";
import I18n from "I18n";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";

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
