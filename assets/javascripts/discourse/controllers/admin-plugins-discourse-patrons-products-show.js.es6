import { popupAjaxError } from "discourse/lib/ajax-error";

export default Ember.Controller.extend({
  actions: {
    createProduct() {
      // TODO: set default group name beforehand
      if (this.get("model.product.groupName") === undefined) {
        this.set(
          "model.product.groupName",
          this.get("model.group.firstObject")
        );
      }

      this.get("model.product")
        .save()
        .then(() => {
          this.transitionToRoute("adminPlugins.discourse-patrons.products");
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
