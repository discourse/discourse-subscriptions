import Component from "@ember/component";
import { action } from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";

export default class CreateCouponForm extends Component {
  discountType = "amount";
  discount = null;
  promoCode = null;
  active = false;

  @discourseComputed
  discountTypes() {
    return [
      { id: "amount", name: "Amount" },
      { id: "percent", name: "Percent" },
    ];
  }

  @action
  createNewCoupon() {
    const createParams = {
      promo: this.promoCode,
      discount_type: this.discountType,
      discount: this.discount,
      active: this.active,
    };

    this.create(createParams);
  }

  @action
  cancelCreate() {
    this.cancel();
  }
}
