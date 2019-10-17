import { ajax } from "discourse/lib/ajax";

const Plan = Discourse.Model.extend({});

Plan.reopenClass({
  findAll() {
    return ajax("/patrons/plans", { method: "get" }).then(result =>
      result.plans.map(plan => Plan.create(plan))
    );
  }
});

export default Plan;
