import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from "I18n";
import Plan from "discourse/plugins/discourse-subscriptions/discourse/models/plan";

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

  @discourseComputed("discount")
  discounted(discount) {
    if (discount) {
      const amount_off = discount.coupon.amount_off;
      const percent_off = discount.coupon.percent_off;

      if (amount_off) {
        return `${parseFloat(amount_off * 0.01).toFixed(2)}`;
      } else if (percent_off) {
        return `${percent_off}%`;
      }
    } else {
      return I18n.t("no_value");
    }
  },

  destroy() {
    return ajax(`/s/user/subscriptions/${this.id}`, {
      method: "delete",
    }).then((result) => UserSubscription.create(result));
  },
});

UserSubscription.reopenClass({
  findAll() {
    return ajax("/s/user/subscriptions", { method: "get" }).then((result) =>
      result.map((subscription) => {
        subscription.plan = Plan.create(subscription.plan);
        return UserSubscription.create(subscription);
      })
    );
  },
});

export default UserSubscription;
