import DiscourseURL from "discourse/lib/url";

export default Ember.Controller.extend({
  actions: {
    destroyProduct(product) {
      product.destroy().then(() =>
        this.controllerFor("adminPluginsDiscoursePatronsProductsIndex")
          .get("model")
          .removeObject(product)
      );
    },

    editProduct(id) {
      return DiscourseURL.redirectTo(
        `/admin/plugins/discourse-patrons/products/${id}`
      );
    }
  }
});
