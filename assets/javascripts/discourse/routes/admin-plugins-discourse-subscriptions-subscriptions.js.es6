import Route from "@ember/routing/route";
import AdminSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/admin-subscription";

export default Route.extend({
  model() {
    return AdminSubscription.find();
  },

  actions: {
    cancelSubscription(subscription) {
      subscription.set("loading", true);
      subscription
        .destroy()
        .then((result) => subscription.set("status", result.status))
        .catch((data) =>
          bootbox.alert(data.jqXHR.responseJSON.errors.join("\n"))
        )
        .finally(() => {
          subscription.set("loading", false);
        });
    },
  },
});
