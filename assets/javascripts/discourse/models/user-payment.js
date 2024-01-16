import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import discourseComputed from "discourse-common/utils/decorators";

const UserPayment = EmberObject.extend({
  @discourseComputed("amount")
  amountDollars(amount) {
    return parseFloat(amount / 100).toFixed(2);
  },
});

UserPayment.reopenClass({
  findAll() {
    return ajax("/s/user/payments", { method: "get" }).then((result) =>
      result.map((payment) => {
        return UserPayment.create(payment);
      })
    );
  },
});

export default UserPayment;
