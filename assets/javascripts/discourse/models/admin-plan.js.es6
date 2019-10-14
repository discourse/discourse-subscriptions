import { ajax } from "discourse/lib/ajax";

const AdminPlan = Discourse.Model.extend({
  name: "",
  interval: "month",
  amount: 0,
  intervals: ["day", "week", "month", "year"],

  destroy() {},

  save() {
    const data = {
      interval: this.interval,
      amount: this.amount,
      name: this.name
    };

    return ajax("/patrons/admin/plans", { method: "post", data });
  }
});

AdminPlan.reopenClass({
  find() {
    return ajax("/patrons/admin/plans", { method: "get" }).then(result =>
      result.map(plan => AdminPlan.create(plan))
    );
  }
});

export default AdminPlan;
