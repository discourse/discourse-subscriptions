import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import discourseComputed from "discourse/lib/decorators";
import getURL from "discourse/lib/get-url";

export default class AdminSubscription extends EmberObject {
  static find() {
    // This now just fetches the data and lets the route handle the new structure.
    return ajax("/s/admin/subscriptions", {
      method: "get",
    });
  }

  //TODO build load more for both lists
  // This function is no longer used by our new template.
  // static loadMore(lastRecord) { ... }

  @discourseComputed("status")
  canceled(status) {
    return status === "canceled";
  }

  @discourseComputed("metadata")
  metadataUserExists(metadata) {
    return metadata && metadata.user_id && metadata.username;
  }

  @discourseComputed("metadata")
  subscriptionUserPath(metadata) {
    if (!this.metadataUserExists) { return; }
    return getURL(`/admin/users/${metadata.user_id}/${metadata.username}`);
  }

  destroy(refund) {
    const data = {
      refund,
    };
    return ajax(`/s/admin/subscriptions/${this.id}`, {
      method: "delete",
      data,
    }).then((result) => AdminSubscription.create(result));
  }
}
