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
      source: this.source,
      plan: this.plan,
      promo: this.promo,
      cardholder_address: this.cardholderAddress,
    };

    return ajax("/s/create", { method: "post", data });
  },
});

Subscription.reopenClass({
  show(id) {
    return ajax(`/s/${id}`, { method: "get" });
  },
});

export default Subscription;
