import { ajax } from "discourse/lib/ajax";

const Product = Discourse.Model.extend({});

Product.reopenClass({
  findAll() {
    return ajax("/s/products", { method: "get" }).then(result =>
      result.map(product => Product.create(product))
    );
  },

  find(id) {
    return ajax(`/s/products/${id}`, { method: "get" }).then(product =>
      Product.create(product)
    );
  }
});

export default Product;
