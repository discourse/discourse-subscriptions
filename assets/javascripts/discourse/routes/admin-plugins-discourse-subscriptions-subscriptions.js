import I18n from "I18n";
import Route from "@ember/routing/route";
import AdminSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/admin-subscription";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";

export default Route.extend({
  dialog: service(),
  model() {
    return AdminSubscription.find();
  },

  @action
  cancelSubscription(model) {
    const subscription = model.subscription;
    const refund = model.refund;
    subscription.set("loading", true);
    subscription
      .destroy(refund)
      .then((result) => {
        subscription.set("status", result.status);
        this.send("closeModal");
        this.dialog.alert(I18n.t("discourse_subscriptions.admin.canceled"));
      })
      .catch((data) =>
        this.dialog.alert(data.jqXHR.responseJSON.errors.join("\n"))
      )
      .finally(() => {
        subscription.set("loading", false);
        this.refresh();
      });
  },
});
