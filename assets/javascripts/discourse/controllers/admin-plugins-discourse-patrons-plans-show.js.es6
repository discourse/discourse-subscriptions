import { popupAjaxError } from "discourse/lib/ajax-error";

export default Ember.Controller.extend({
  actions: {
    createPlan() {
      let product;

      if(this.get("model.plan.product_id")) {
        product = this.get("model.products")
          .filterBy('id', this.get("model.plan.product_id"))
          .get("firstObject");
      }
      else {
        product = this.get("model.products").get("firstObject");
      }

      this.set("model.plan.product", product);

      this.get("model.plan")
        .save()
        .then(() => {
          this.transitionToRoute("adminPlugins.discourse-patrons.plans");
        })
        .catch(popupAjaxError);
    }
  }
});
