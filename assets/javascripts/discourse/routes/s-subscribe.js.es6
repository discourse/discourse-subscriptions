import Product from "discourse/plugins/discourse-subscriptions/discourse/models/product";

export default Discourse.Route.extend({
  model() {
    return Product.findAll();
  }
});
