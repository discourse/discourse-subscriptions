import { popupAjaxError } from "discourse/lib/ajax-error";

export default Ember.Controller.extend({
  actions: {
    cancelProduct() {
      this.transitionToRoute("adminPlugins.discourse-patrons.products");
    },

    createProduct() {
      this.get("model.product")
        .save()
        .then(product => {
          this.transitionToRoute(
            "adminPlugins.discourse-patrons.products.show",
            product.id
          );
        })
        .catch(popupAjaxError);
    },

    updateProduct() {
      this.get("model.product")
        .update()
        .then(() => {
          this.transitionToRoute("adminPlugins.discourse-patrons.products");
        })
        .catch(popupAjaxError);
    }
  }
});
