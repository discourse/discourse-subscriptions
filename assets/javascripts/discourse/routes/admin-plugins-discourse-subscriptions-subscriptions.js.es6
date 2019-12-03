import AdminSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/admin-subscription";

export default Discourse.Route.extend({
  model() {
    return AdminSubscription.find();
  },

  actions: {
    cancelSubscription(subscription) {
      bootbox.confirm(
        I18n.t(
          "discourse_subscriptions.user.subscriptions.operations.destroy.confirm"
        ),
        I18n.t("no_value"),
        I18n.t("yes_value"),
        confirmed => {
          if (confirmed) {
            subscription.set("loading", true);

            subscription
              .destroy()
              .then(result => subscription.set("status", result.status))
              .catch(data =>
                bootbox.alert(data.jqXHR.responseJSON.errors.join("\n"))
              )
              .finally(() => {
                subscription.set("loading", false);
              });
          }
        }
      );
    }
  }
});
