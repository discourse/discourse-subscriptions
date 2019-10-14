import { ajax } from "discourse/lib/ajax";

const AdminSubscription = Discourse.Model.extend({});

AdminSubscription.reopenClass({
  find() {
    return ajax("/patrons/admin/subscriptions", { method: "get" }).then(result =>
      result.data.map(subscription => AdminSubscription.create(subscription))
    );
  }
});

export default AdminSubscription;
