import Controller from "@ember/controller";
import AdminCoupon from "discourse/plugins/discourse-subscriptions/discourse/models/admin-coupon";
import { popupAjaxError } from "discourse/lib/ajax-error";

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
  },
});
