import computed from "ember-addons/ember-computed-decorators";
import { ajax } from "discourse/lib/ajax";

const Subscription = Discourse.Model.extend({
  @computed("status")
  canceled(status) {
    return status === "canceled";
  },

  save() {
    const data = {
      customer: this.customer,
      plan: this.plan
    };

    return ajax("/s/subscriptions", { method: "post", data });
  }
});

Subscription.reopenClass({
  findAll() {
    return ajax("/s/subscriptions", { method: "get" }).then(result =>
      result.map(subscription => Subscription.create(subscription))
    );
  }
});

export default Subscription;
