import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import discourseComputed from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import Plan from "discourse/plugins/discourse-subscriptions/discourse/models/plan";

export default class UserSubscription extends EmberObject {
  static findAll() {
    // This is correct: just fetch the data and let the route handle it.
    return ajax("/s/user/subscriptions", { method: "get" });
  }

  @discourseComputed("status")
  canceled(status) {
    return status === "canceled";
  }

  @discourseComputed("current_period_end", "canceled_at")
  endDate(current_period_end, canceled_at) {
    // This is the safer version that handles one-time payments
    if (current_period_end) {
      return moment.unix(current_period_end).format("LL");
    } else if (canceled_at) {
      return i18n("discourse_subscriptions.user.subscriptions.cancelled");
    } else {
      return "N/A"; // For our one-time Razorpay purchases
    }
  }

  @discourseComputed("discount")
  discounted(discount) {
    // This is the safer version that handles missing discounts
    if (discount && discount.coupon) {
      const amount_off = discount.coupon.amount_off;
      const percent_off = discount.coupon.percent_off;

      if (amount_off) {
        return `${parseFloat(amount_off * 0.01).toFixed(2)}`;
      } else if (percent_off) {
        return `${percent_off}%`;
      }
    } else {
      return i18n("no_value");
    }
  }

  // --- THIS METHOD IS NOW CORRECTLY INCLUDED ---
  destroy() {
    return ajax(`/s/user/subscriptions/${this.id}`, {
      method: "delete",
    }).then((result) => UserSubscription.create(result));
  }
}
