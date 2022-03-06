import Route from "@ember/routing/route";
import AdminCoupon from "discourse/plugins/discourse-subscriptions/discourse/models/admin-coupon";
import { action } from "@ember/object";

export default Route.extend({
  model() {
    return AdminCoupon.list();
  },

  @action
  reloadModel() {
    this.refresh();
  },
});
