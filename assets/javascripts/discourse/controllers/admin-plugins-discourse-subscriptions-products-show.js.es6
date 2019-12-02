import { popupAjaxError } from "discourse/lib/ajax-error";

export default Ember.Controller.extend({
  actions: {
    cancelProduct() {
      this.transitionToRoute("adminPlugins.discourse-subscriptions.products");
    },

    createProduct() {
      this.get("model.product")
        .save()
        .then(product => {
          this.transitionToRoute(
            "adminPlugins.discourse-subscriptions.products.show",
            product.id
          );
        })
        .catch(popupAjaxError);
    },

    updateProduct() {
      this.get("model.product")
        .update()
        .then(() => {
          this.transitionToRoute(
            "adminPlugins.discourse-subscriptions.products"
          );
        })
        .catch(popupAjaxError);
    }
  }
});
