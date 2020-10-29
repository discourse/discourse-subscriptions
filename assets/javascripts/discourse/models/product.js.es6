import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { default as getURL } from "discourse-common/lib/get-url";

const Product = EmberObject.extend({});

Product.reopenClass({
  findAll() {
    return ajax(getURL("/s"), { method: "get" }).then((result) =>
      result.map((product) => Product.create(product))
    );
  },
});

export default Product;
