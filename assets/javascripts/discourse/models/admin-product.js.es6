import { ajax } from "discourse/lib/ajax";

const AdminProduct = Discourse.Model.extend({
  destroy() {},

  save() {
    const data = {};

    return ajax("/patrons/admin/products", { method: "post", data });
  }
});

AdminProduct.reopenClass({
  find() {
    return ajax("/patrons/admin/products", { method: "get" }).then(result =>
      result.map(product => AdminProduct.create(product))
    );
  }
});

export default AdminProduct;
