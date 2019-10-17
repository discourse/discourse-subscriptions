import { ajax } from "discourse/lib/ajax";

const AdminPlan = Discourse.Model.extend({
  name: "",
  interval: "month",
  amount: 0,
  intervals: ["day", "week", "month", "year"],

  destroy() {
    return ajax(`/patrons/admin/plans/${this.id}`, { method: "delete" });
  },

  save() {
    const data = {
      interval: this.interval,
      amount: this.amount,
      name: this.name,
      product: {
        id: this.product.id,
        // name: this.product.name
      }
    };

    console.log(12, data);

    return ajax("/patrons/admin/plans", { method: "post", data });
  }
});

AdminPlan.reopenClass({
  findAll() {
    return ajax("/patrons/admin/plans", { method: "get" }).then(result =>
      result.map(plan => AdminPlan.create(plan))
    );
  }
});

export default AdminPlan;
