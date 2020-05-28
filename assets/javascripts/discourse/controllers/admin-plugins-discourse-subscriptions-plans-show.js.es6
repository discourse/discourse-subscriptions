import Controller from "@ember/controller";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Controller.extend({
  actions: {
    createPlan() {
      if (this.get("model.plan.product_id") === undefined) {
        const productID = this.get("model.products.firstObject.id");
        this.set("model.plan.product_id", productID);
      }

      this.get("model.plan")
        .save()
        .then(() => {
          this.transitionToRoute("adminPlugins.discourse-subscriptions.plans");
        })
        .catch(popupAjaxError);
    }
  }
});
