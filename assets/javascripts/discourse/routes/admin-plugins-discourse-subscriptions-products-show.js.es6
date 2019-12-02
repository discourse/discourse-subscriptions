import AdminProduct from "discourse/plugins/discourse-subscriptions/discourse/models/admin-product";
import AdminPlan from "discourse/plugins/discourse-subscriptions/discourse/models/admin-plan";

export default Discourse.Route.extend({
  model(params) {
    const product_id = params["product-id"];
    let product;
    let plans = [];

    if (product_id === "new") {
      product = AdminProduct.create({ active: true, isNew: true });
    } else {
      product = AdminProduct.find(product_id);
      plans = AdminPlan.findAll({ product_id });
    }

    return Ember.RSVP.hash({ plans, product });
  },

  actions: {
    destroyPlan(plan) {
      bootbox.confirm(
        I18n.t("discourse_patrons.admin.plans.operations.destroy.confirm"),
        I18n.t("no_value"),
        I18n.t("yes_value"),
        confirmed => {
          if (confirmed) {
            plan
              .destroy()
              .then(() => {
                this.controllerFor("adminPluginsDiscourseSubscriptionsProductsShow")
                  .get("model.plans")
                  .removeObject(plan);
              })
              .catch(data =>
                bootbox.alert(data.jqXHR.responseJSON.errors.join("\n"))
              );
          }
        }
      );
    }
  }
});
