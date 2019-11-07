import { ajax } from "discourse/lib/ajax";

const Product = Discourse.Model.extend({});

Product.reopenClass({
  findAll() {
    return ajax("/patrons/products", { method: "get" }).then(result =>
      result.map(product => Product.create(product))
    );
  },

  find(id) {
    return ajax(`/patrons/products/${id}`, { method: "get" }).then(product =>
      Product.create(product)
    );
  }
});

export default Product;
