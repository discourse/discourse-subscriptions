import computed from "ember-addons/ember-computed-decorators";
import { ajax } from "discourse/lib/ajax";

const AdminSubscription = Discourse.Model.extend({
  @computed("metadata")
  metadataUserExists(metadata) {
    return metadata.user_id && metadata.username;
  },

  @computed("metadata")
  subscriptionUserPath(metadata) {
    return Discourse.getURL(
      `/admin/users/${metadata.user_id}/${metadata.username}`
    );
  }
});

AdminSubscription.reopenClass({
  find() {
    return ajax("/patrons/admin/subscriptions", { method: "get" }).then(
      result =>
        result.data.map(subscription => AdminSubscription.create(subscription))
    );
  }
});

export default AdminSubscription;
