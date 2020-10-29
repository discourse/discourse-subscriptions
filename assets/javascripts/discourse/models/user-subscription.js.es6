import EmberObject from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";
import Plan from "discourse/plugins/discourse-subscriptions/discourse/models/plan";
import I18n from "I18n";
import { default as getURL } from "discourse-common/lib/get-url";

const UserSubscription = EmberObject.extend({
  @discourseComputed("status")
  canceled(status) {
    return status === "canceled";
  },

  @discourseComputed("current_period_end", "canceled_at")
  endDate(current_period_end, canceled_at) {
    if (!canceled_at) {
      return moment.unix(current_period_end).format("LL");
    } else {
      return I18n.t("discourse_subscriptions.user.subscriptions.cancelled");
    }
  },

  destroy() {
    return ajax(getURL(`/s/user/subscriptions/${this.id}`), {
      method: "delete",
    }).then((result) => UserSubscription.create(result));
  },
});

UserSubscription.reopenClass({
  findAll() {
    return ajax(getURL("/s/user/subscriptions"), { method: "get" }).then(
      (result) =>
        result.map((subscription) => {
          subscription.plan = Plan.create(subscription.plan);
          return UserSubscription.create(subscription);
        })
    );
  },
});

export default UserSubscription;
