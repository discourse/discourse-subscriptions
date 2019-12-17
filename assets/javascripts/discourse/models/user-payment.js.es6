import EmberObject from "@ember/object";
import computed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";

const UserPayment = EmberObject.extend({
  @computed("amount")
  amountDollars(amount){
    return parseFloat(amount / 100).toFixed(2);
  }
});

UserPayment.reopenClass({
  findAll() {
    return ajax("/s/user/payments", { method: "get" }).then(result =>
      result.map(payment => {
        return UserPayment.create(payment);
      })
    );
  }
});

export default UserPayment;
