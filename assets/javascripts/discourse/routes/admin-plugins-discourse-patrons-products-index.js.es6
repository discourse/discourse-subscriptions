import AdminProduct from "discourse/plugins/discourse-patrons/discourse/models/admin-product";

export default Discourse.Route.extend({
  model() {
    return AdminProduct.find();
  },

  actions: {
    destroyProduct(product) {
      bootbox.confirm(
        I18n.t("discourse_patrons.admin.products.operations.destroy.confirm"),
        I18n.t("no_value"),
        I18n.t("yes_value"),
        confirmed => {
          if (confirmed) {
            this.controllerFor("adminPluginsDiscoursePatronsProductsIndex")
              .get("model")
              .removeObject(product);
          }
        }
      );
    }
  }
});
