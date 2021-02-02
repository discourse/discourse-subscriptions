import discourseComputed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";
import EmberObject from "@ember/object";
import getURL from "discourse-common/lib/get-url";

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
    return getURL(`/admin/users/${metadata.user_id}/${metadata.username}`);
  },

  destroy(refund) {
    const data = {
      refund: refund,
    };
    return ajax(`/s/admin/subscriptions/${this.id}`, {
      method: "delete",
      data,
    }).then((result) => AdminSubscription.create(result));
  },
});

AdminSubscription.reopenClass({
  find() {
    return ajax("/s/admin/subscriptions", {
      method: "get",
    }).then((result) => {
      if (result === null) {
        return { unconfigured: true };
      }
      result.data = result.data.map((subscription) =>
        AdminSubscription.create(subscription)
      );
      return result;
    });
  },
  loadMore(page) {
    return ajax(`/s/admin/subscriptions?page=${page}`, {
      method: "get",
    }).then((result) => {
      result.data = result.data.map((subscription) =>
        AdminSubscription.create(subscription)
      );
      return result;
    });
  },
});

export default AdminSubscription;
