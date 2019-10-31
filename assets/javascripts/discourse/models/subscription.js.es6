import computed from "ember-addons/ember-computed-decorators";
import { ajax } from "discourse/lib/ajax";
import Plan from "discourse/plugins/discourse-patrons/discourse/models/plan";

const Subscription = Discourse.Model.extend({
  @computed("created")
  createdFormatted(created) {
    return moment.unix(created).format();
  },

  @computed("status")
  canceled(status) {
    return status === 'canceled';
  },

  save() {
    const data = {
      customer: this.customer,
      plan: this.plan
    };

    return ajax("/patrons/subscriptions", { method: "post", data });
  },

  destroy() {
    return ajax(`/patrons/subscriptions/${this.id}`, { method: "delete" }).then(result =>
      Subscription.create(result)
    );
  },
});

Subscription.reopenClass({
  findAll() {
    return ajax("/patrons/subscriptions", { method: "get" }).then(result =>
      result.map(subscription => {
        subscription.plan = Plan.create(subscription.plan);
        return Subscription.create(subscription)
      })
    );
  }
});

export default Subscription;
