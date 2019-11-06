import Product from "discourse/plugins/discourse-patrons/discourse/models/product";

export default Discourse.Route.extend({
  model() {
    return Product.findAll();
  }
});
