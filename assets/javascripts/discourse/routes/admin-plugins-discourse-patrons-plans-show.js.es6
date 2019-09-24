import { ajax } from "discourse/lib/ajax";

export default Discourse.Route.extend({
  model() {
    return Ember.Object.create({
      name: "",
      interval: "month",
      amount: 0,
      intervals: ["day", "week", "month", "year"],

      save() {
        const data = {
          interval: this.interval,
          amount: this.amount,
          name: this.name
        };

        return ajax("/patrons/admin/plans", { method: "post", data });
      }
    });
  }
});
