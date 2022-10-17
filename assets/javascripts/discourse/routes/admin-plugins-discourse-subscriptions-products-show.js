import Route from "@ember/routing/route";
import AdminProduct from "discourse/plugins/discourse-subscriptions/discourse/models/admin-product";
import AdminPlan from "discourse/plugins/discourse-subscriptions/discourse/models/admin-plan";
import I18n from "I18n";
import { hash } from "rsvp";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";

export default Route.extend({
  dialog: service(),
  model(params) {
    const product_id = params["product-id"];
    let product;
    let plans = [];

    if (product_id === "new") {
      product = AdminProduct.create({ active: false, isNew: true });
    } else {
      product = AdminProduct.find(product_id);
      plans = AdminPlan.findAll({ product_id });
    }

    return hash({ plans, product });
  },

  @action
  destroyPlan(plan) {
    this.dialog.yesNoConfirm({
      message: I18n.t(
        "discourse_subscriptions.admin.plans.operations.destroy.confirm"
      ),
      didConfirm: () => {
        plan
          .destroy()
          .then(() => {
            this.controllerFor("adminPluginsDiscourseSubscriptionsProductsShow")
              .get("model.plans")
              .removeObject(plan);
          })
          .catch((data) =>
            this.dialog.alert(data.jqXHR.responseJSON.errors.join("\n"))
          );
      },
    });
  },
});
