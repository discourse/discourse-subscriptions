import discourseComputed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";
import EmberObject from "@ember/object";

const Subscription = EmberObject.extend({
  @discourseComputed("status")
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
  },

  finalize(plan, transaction) {
    const data = {
      plan: plan,
      transaction: transaction
    };

    return ajax("/s/subscriptions/finalize", { method: "post", data });
  }
});

export default Subscription;
