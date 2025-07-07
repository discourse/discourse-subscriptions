import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import discourseComputed from "discourse/lib/decorators";
import getURL from "discourse/lib/get-url";
import formatCurrency from "../helpers/format-currency";

export default class AdminSubscription extends EmberObject {
  // FIX: The find method now accepts parameters to pass to the API
  static find(params) {
    return ajax("/s/admin/subscriptions.json", {
      method: "get",
      data: params,
    });
  }

  @discourseComputed("status")
  canceled(status) {
    return status === "canceled";
  }

  @discourseComputed("metadata")
  metadataUserExists(metadata) {
    return metadata && metadata.user_id && metadata.username;
  }

  @discourseComputed("metadata")
  subscriptionUserPath(metadata) {
    if (!this.metadataUserExists) { return; }
    return getURL(`/admin/users/${metadata.user_id}/${metadata.username}`);
  }

  @discourseComputed("unit_amount", "currency")
  amountDollars(unit_amount, currency) {
    if (unit_amount !== undefined && currency) {
      const amount = parseFloat(unit_amount / 100).toFixed(2);
      return formatCurrency(currency, amount);
    }
    return "";
  }

  destroy(refund) {
    const data = { refund };
    return ajax(`/s/admin/subscriptions/${this.id}`, {
      method: "delete",
      data,
    }).then((result) => AdminSubscription.create(result));
  }
}
