import discourseComputed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";
import EmberObject from "@ember/object";
import { default as getURL } from "discourse-common/lib/get-url";

const Subscription = EmberObject.extend({
  @discourseComputed("status")
  canceled(status) {
    return status === "canceled";
  },

  save() {
    const data = {
      source: this.source,
      plan: this.plan,
    };

    return ajax(getURL("/s/create"), { method: "post", data });
  },
});

Subscription.reopenClass({
  show(id) {
    return ajax(getURL(`/s/${id}`), { method: "get" });
  },
});

export default Subscription;
