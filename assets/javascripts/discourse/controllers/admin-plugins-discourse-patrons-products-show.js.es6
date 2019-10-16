import { popupAjaxError } from "discourse/lib/ajax-error";

export default Ember.Controller.extend({
  actions: {
    createProduct() {
      // TODO: set default group name beforehand
      if (this.get("model.product.metadata.group_name") === undefined) {
        this.set(
          "model.product.metadata",
          { group_name: this.get("model.groups.firstObject.name") }
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
