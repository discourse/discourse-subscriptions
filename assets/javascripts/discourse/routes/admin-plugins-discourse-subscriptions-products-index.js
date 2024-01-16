import { action } from "@ember/object";
import Route from "@ember/routing/route";
import { inject as service } from "@ember/service";
import I18n from "I18n";
import AdminProduct from "discourse/plugins/discourse-subscriptions/discourse/models/admin-product";

export default Route.extend({
  dialog: service(),

  model() {
    return AdminProduct.findAll();
  },

  @action
  destroyProduct(product) {
    this.dialog.yesNoConfirm({
      message: I18n.t(
        "discourse_subscriptions.admin.products.operations.destroy.confirm"
      ),
      didConfirm: () => {
        return product
          .destroy()
          .then(() => {
            this.controllerFor(
              "adminPluginsDiscourseSubscriptionsProductsIndex"
            )
              .get("model")
              .removeObject(product);
          })
          .catch((data) =>
            this.dialog.alert(data.jqXHR.responseJSON.errors.join("\n"))
          );
      },
    });
  },
});
