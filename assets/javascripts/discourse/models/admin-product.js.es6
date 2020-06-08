import { ajax } from "discourse/lib/ajax";
import EmberObject from "@ember/object";

const AdminProduct = EmberObject.extend({
  isNew: false,
  metadata: {},

  destroy() {
    return ajax(`/s/admin/products/${this.id}`, { method: "delete" });
  },

  save() {
    const data = {
      name: this.name,
      statement_descriptor: this.statement_descriptor,
      metadata: this.metadata,
      active: this.active
    };

    return ajax("/s/admin/products", {
      method: "post",
      data
    }).then(product => AdminProduct.create(product));
  },

  update() {
    const data = {
      name: this.name,
      statement_descriptor: this.statement_descriptor,
      metadata: this.metadata,
      active: this.active
    };

    return ajax(`/s/admin/products/${this.id}`, {
      method: "patch",
      data
    });
  }
});

AdminProduct.reopenClass({
  findAll() {
    return ajax("/s/admin/products", { method: "get" }).then(result => {
      if (result === null) {
        return { unconfigured: true };
      }
      return result.map(product => AdminProduct.create(product));
    });
  },

  find(id) {
    return ajax(`/s/admin/products/${id}`, {
      method: "get"
    }).then(product => AdminProduct.create(product));
  }
});

export default AdminProduct;
