import { ajax } from "discourse/lib/ajax";

const AdminPlan = Discourse.Model.extend({
  destroy() {}
});

AdminPlan.reopenClass({
  find() {
    return ajax("/patrons/admin/plans", { method: "get" }).then(result =>
      result.map(plan => AdminPlan.create(plan))
    );
  }
});

export default AdminPlan;
