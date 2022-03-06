import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  @discourseComputed
  discountTypes() {
    return [
      { id: "amount", name: "Amount" },
      { id: "percent", name: "Percent" },
    ];
  },
  discountType: "amount",
  discount: null,
  promoCode: null,
  active: false,

  actions: {
    createNewCoupon() {
      const createParams = {
        promo: this.promoCode,
        discount_type: this.discountType,
        discount: this.discount,
        active: this.active,
      };

      this.create(createParams);
    },
    cancelCreate() {
      this.cancel();
    },
  },
});
