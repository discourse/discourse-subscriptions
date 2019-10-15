import { ajax } from "discourse/lib/ajax";

const AdminProduct = Discourse.Model.extend({
  destroy() {
    return ajax(`/patrons/admin/products/${this.id}`, { method: "delete" });
  },

  save() {
    const data = {
      name: this.name,
      groupName: this.groupName,
      active: this.active
    };

    return ajax("/patrons/admin/products", { method: "post", data });
  }
});

AdminProduct.reopenClass({
  findAll() {
    return ajax("/patrons/admin/products", { method: "get" }).then(result =>
      result.map(product => AdminProduct.create(product))
    );
  }
});

export default AdminProduct;
