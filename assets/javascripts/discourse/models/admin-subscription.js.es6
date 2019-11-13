import EmberObject from "@ember/object";
import computed from "ember-addons/ember-computed-decorators";
import { ajax } from "discourse/lib/ajax";

const AdminSubscription = Discourse.Model.extend({
  @computed("metadata")
  user(metadata) {
    console.log(metadata);
    if (metadata.user_id && metadata.username) {
      return EmberObject.create({
        id: metadata.user_id,
        username: metadata.username
      });
    }
    return false;
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
