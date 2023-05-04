import Route from "@ember/routing/route";
import Product from "discourse/plugins/discourse-subscriptions/discourse/models/product";

export default Route.extend({
  model() {
    return Product.findAll();
  },

  afterModel(products) {
    if (products.length === 1) {
      const product = products[0];

      if (this.currentUser && product.subscribed && !product.repurchaseable) {
        this.transitionTo(
          "user.billing.subscriptions",
          this.currentUser.username
        );
      } else {
        this.transitionTo("subscribe.show", product.id);
      }
    }
  },
});
