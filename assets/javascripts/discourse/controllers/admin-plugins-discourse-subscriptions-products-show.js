import Controller from "@ember/controller";
import { inject as service } from "@ember/service";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Controller.extend({
  router: service(),

  actions: {
    cancelProduct() {
      this.router.transitionTo("adminPlugins.discourse-subscriptions.products");
    },

    createProduct() {
      this.get("model.product")
        .save()
        .then((product) => {
          this.router.transitionTo(
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
          this.router.transitionTo(
            "adminPlugins.discourse-subscriptions.products"
          );
        })
        .catch(popupAjaxError);
    },
  },
});
