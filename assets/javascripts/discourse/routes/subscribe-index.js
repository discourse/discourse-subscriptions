import Route from "@ember/routing/route";
import Product from "discourse/plugins/discourse-subscriptions/discourse/models/product";
import { inject as service } from "@ember/service";

export default Route.extend({
  router: service(),

  model() {
    return Product.findAll();
  },

  afterModel(products) {
    if (products.length === 1) {
      const product = products[0];

      if (this.currentUser && product.subscribed && !product.repurchaseable) {
        this.router.transitionTo(
          "user.billing.subscriptions",
          this.currentUser.username
        );
      } else {
        this.router.transitionTo("subscribe.show", product.id);
      }
    }
  },
});
