import discourseComputed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";
import EmberObject from "@ember/object";

const AdminSubscription = EmberObject.extend({
  @discourseComputed("status")
  canceled(status) {
    return status === "canceled";
  },

  @discourseComputed("metadata")
  metadataUserExists(metadata) {
    return metadata.user_id && metadata.username;
  },

  @discourseComputed("metadata")
  subscriptionUserPath(metadata) {
    return Discourse.getURL(
      `/admin/users/${metadata.user_id}/${metadata.username}`
    );
  },

  destroy() {
    return ajax(`/s/admin/subscriptions/${this.id}`, {
      method: "delete"
    }).then(result => AdminSubscription.create(result));
  }
});

AdminSubscription.reopenClass({
  find() {
    return ajax("/s/admin/subscriptions", {
      method: "get"
    }).then(result => {
      if (result === null) {
        return { unconfigured: true };
      }
      result.map(subscription => AdminSubscription.create(subscription));
    });
  }
});

export default AdminSubscription;
