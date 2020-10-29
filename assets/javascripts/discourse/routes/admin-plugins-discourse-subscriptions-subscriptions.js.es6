import I18n from "I18n";
import Route from "@ember/routing/route";
import AdminSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/admin-subscription";

export default Route.extend({
  model() {
    return AdminSubscription.find();
  },

  actions: {
    cancelSubscription(model) {
      const subscription = model.subscription;
      const refund = model.refund;
      subscription.set("loading", true);
      subscription
        .destroy(refund)
        .then((result) => {
          subscription.set("status", result.status);
          this.send("closeModal");
          bootbox.alert(I18n.t("discourse_subscriptions.admin.canceled"));
        })
        .catch((data) =>
          bootbox.alert(data.jqXHR.responseJSON.errors.join("\n"))
        )
        .finally(() => {
          subscription.set("loading", false);
          this.refresh();
        });
    },
  },
});
