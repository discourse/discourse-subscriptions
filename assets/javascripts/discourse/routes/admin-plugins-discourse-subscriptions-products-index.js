import Route from "@ember/routing/route";
import AdminProduct from "discourse/plugins/discourse-subscriptions/discourse/models/admin-product";
import I18n from "I18n";
import { action } from "@ember/object";
import bootbox from "bootbox";

export default Route.extend({
  model() {
    return AdminProduct.findAll();
  },

  @action
  destroyProduct(product) {
    bootbox.confirm(
      I18n.t(
        "discourse_subscriptions.admin.products.operations.destroy.confirm"
      ),
      I18n.t("no_value"),
      I18n.t("yes_value"),
      (confirmed) => {
        if (confirmed) {
          product
            .destroy()
            .then(() => {
              this.controllerFor(
                "adminPluginsDiscourseSubscriptionsProductsIndex"
              )
                .get("model")
                .removeObject(product);
            })
            .catch((data) =>
              bootbox.alert(data.jqXHR.responseJSON.errors.join("\n"))
            );
        }
      }
    );
  },
});
