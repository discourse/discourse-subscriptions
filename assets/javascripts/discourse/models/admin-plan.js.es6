import Plan from "discourse/plugins/discourse-subscriptions/discourse/models/plan";
import discourseComputed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";

const AdminPlan = Plan.extend({
  isNew: false,
  name: "",
  interval: "month",
  amount: 0,
  intervals: ["day", "week", "month", "year"],
  metadata: {},

  @discourseComputed("trial_period_days")
  parseTrialPeriodDays(trial_period_days) {
    if (trial_period_days) {
      return parseInt(0 + trial_period_days, 10);
    } else {
      return 0;
    }
  },

  destroy() {
    return ajax(`/s/admin/plans/${this.id}`, { method: "delete" });
  },

  save() {
    const data = {
      nickname: this.nickname,
      interval: this.interval,
      amount: this.amount,
      currency: this.currency,
      trial_period_days: this.parseTrialPeriodDays,
      product: this.product,
      metadata: this.metadata,
      active: this.active
    };

    return ajax("/s/admin/plans", { method: "post", data });
  },

  update() {
    const data = {
      nickname: this.nickname,
      trial_period_days: this.parseTrialPeriodDays,
      metadata: this.metadata,
      active: this.active
    };

    return ajax(`/s/admin/plans/${this.id}`, { method: "patch", data });
  }
});

AdminPlan.reopenClass({
  findAll(data) {
    return ajax("/s/admin/plans", { method: "get", data }).then(result =>
      result.map(plan => AdminPlan.create(plan))
    );
  },

  find(id) {
    return ajax(`/s/admin/plans/${id}`, { method: "get" }).then(plan =>
      AdminPlan.create(plan)
    );
  }
});

export default AdminPlan;
