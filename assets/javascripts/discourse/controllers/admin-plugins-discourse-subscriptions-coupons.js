import Controller from "@ember/controller";
import { popupAjaxError } from "discourse/lib/ajax-error";
import AdminCoupon from "discourse/plugins/discourse-subscriptions/discourse/models/admin-coupon";

export default Controller.extend({
  creating: null,

  actions: {
    openCreateForm() {
      this.set("creating", true);
    },
    closeCreateForm() {
      this.set("creating", false);
    },
    createNewCoupon(params) {
      AdminCoupon.save(params)
        .then(() => {
          this.send("closeCreateForm");
          this.send("reloadModel");
        })
        .catch(popupAjaxError);
    },
    deleteCoupon(coupon) {
      AdminCoupon.destroy(coupon)
        .then(() => {
          this.send("reloadModel");
        })
        .catch(popupAjaxError);
    },
    toggleActive(coupon) {
      const couponData = {
        id: coupon.id,
        active: !coupon.active,
      };
      AdminCoupon.update(couponData)
        .then(() => {
          this.send("reloadModel");
        })
        .catch(popupAjaxError);
    },
  },
});
