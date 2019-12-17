import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";

const Payment = EmberObject.extend({
  save() {
    const data = {
      payment_method: this.payment_method,
      amount: this.amount,
      currency: this.currency
    };

    return ajax("/s/payments", { method: "post", data });
  }
});

export default Payment;
