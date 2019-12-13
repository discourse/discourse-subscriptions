import Route from "@ember/routing/route";
import Product from "discourse/plugins/discourse-subscriptions/discourse/models/product";

export default Route.extend({
  model() {
    return Product.findAll();
  }
});
