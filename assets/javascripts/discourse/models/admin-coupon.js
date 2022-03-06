import { ajax } from "discourse/lib/ajax";
import EmberObject from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";

const AdminCoupon = EmberObject.extend({
  @discourseComputed("coupon.amount_off", "coupon.percent_off")
  discount(amount_off, percent_off) {
    if (amount_off) {
      return `${parseFloat(amount_off * 0.01).toFixed(2)}`;
    } else if (percent_off) {
      return `${percent_off}%`;
    }
  },
});

AdminCoupon.reopenClass({
  list() {
    return ajax("/s/admin/coupons", {
      method: "get",
    }).then((result) => {
      if (result === null) {
        return { unconfigured: true };
      }
      return result.map((coupon) => AdminCoupon.create(coupon));
    });
  },
  save(params) {
    const data = {
      promo: params.promo,
      discount_type: params.discount_type,
      discount: params.discount,
      active: params.active,
    };

    return ajax("/s/admin/coupons", {
      method: "post",
      data,
    }).then((coupon) => AdminCoupon.create(coupon));
  },

  update(params) {
    const data = {
      id: params.id,
      active: params.active,
    };

    return ajax("/s/admin/coupons", {
      method: "put",
      data,
    }).then((coupon) => AdminCoupon.create(coupon));
  },

  destroy(params) {
    const data = {
      coupon_id: params.coupon.id,
    };
    return ajax("/s/admin/coupons", {
      method: "delete",
      data,
    });
  },
});

export default AdminCoupon;
