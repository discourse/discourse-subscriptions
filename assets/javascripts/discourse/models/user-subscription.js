import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import discourseComputed from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import Plan from "discourse/plugins/discourse-subscriptions/discourse/models/plan";
import formatCurrency from "../helpers/format-currency"; // Import the helper

export default class UserSubscription extends EmberObject {
  static findAll() {
    return ajax("/s/user/subscriptions", { method: "get" });
  }

  // FIX: This now watches `unit_amount` and correctly formats the currency.
  @discourseComputed("unit_amount", "currency")
  amountDollars(unit_amount, currency) {
    if (unit_amount !== undefined && currency) {
      const amount = parseFloat(unit_amount / 100).toFixed(2);
      return formatCurrency(currency, amount);
    }
  }

  @discourseComputed("status")
  canceled(status) {
    return status === "canceled";
  }

  @discourseComputed("renews_at", "status")
  endDate(renews_at, status) {
    if (status === "canceled") {
      return i18n("discourse_subscriptions.user.subscriptions.cancelled");
    }
    if (renews_at) {
      return moment.unix(renews_at).format("LL");
    }
  }

  @discourseComputed("discount")
  discounted(discount) {
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

  destroy() {
    return ajax(`/s/user/subscriptions/${this.id}`, {
      method: "delete",
    }).then((result) => UserSubscription.create(result));
  }
}
