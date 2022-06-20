import Route from "@ember/routing/route";
import UserSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/user-subscription";
import I18n from "I18n";
import { action } from "@ember/object";
import bootbox from "bootbox";

export default Route.extend({
  model() {
    return UserSubscription.findAll();
  },

  @action
  updateCard(subscriptionId) {
    this.transitionTo("user.billing.subscriptions.card", subscriptionId);
  },
  @action
  cancelSubscription(subscription) {
    bootbox.confirm(
      I18n.t(
        "discourse_subscriptions.user.subscriptions.operations.destroy.confirm"
      ),
      I18n.t("no_value"),
      I18n.t("yes_value"),
      (confirmed) => {
        if (confirmed) {
          subscription.set("loading", true);

          subscription
            .destroy()
            .then((result) => subscription.set("status", result.status))
            .catch((data) =>
              bootbox.alert(data.jqXHR.responseJSON.errors.join("\n"))
            )
            .finally(() => {
              subscription.set("loading", false);
              this.refresh();
            });
        }
      }
    );
  },
});
