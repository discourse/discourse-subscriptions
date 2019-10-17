import { ajax } from "discourse/lib/ajax";

const Subscription = Discourse.Model.extend({
  save() {
    const data = {
      customer: this.customer,
      plan: this.plan
    };

    return ajax("/patrons/subscriptions", { method: "post", data });
  }
});

export default Subscription;
