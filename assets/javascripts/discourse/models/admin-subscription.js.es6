import computed from "ember-addons/ember-computed-decorators";
import { ajax } from "discourse/lib/ajax";

const AdminSubscription = Discourse.Model.extend({
  @computed("created")
  createdFormatted(created) {
    return moment.unix(created).format();
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
