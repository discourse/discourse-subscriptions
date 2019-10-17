import { ajax } from "discourse/lib/ajax";

const AdminProduct = Discourse.Model.extend({
  isNew: false,
  metadata: {},

  destroy() {
    return ajax(`/patrons/admin/products/${this.id}`, { method: "delete" });
  },

  save() {
    const data = {
      name: this.name,
      statement_descriptor: this.statement_descriptor,
      metadata: this.metadata,
      active: this.active
    };

    return ajax("/patrons/admin/products", { method: "post", data });
  },

  update() {
    const data = {
      name: this.name,
      statement_descriptor: this.statement_descriptor,
      metadata: this.metadata,
      active: this.active
    };

    return ajax(`/patrons/admin/products/${this.id}`, { method: "patch", data });
  }
});

AdminProduct.reopenClass({
  findAll() {
    return ajax("/patrons/admin/products", { method: "get" }).then(result =>
      result.map(product => AdminProduct.create(product))
    );
  },

  find(id) {
    return ajax(`/patrons/admin/products/${id}`, { method: "get" }).then(product =>
      AdminProduct.create(product)
    );
  },
});

export default AdminProduct;
