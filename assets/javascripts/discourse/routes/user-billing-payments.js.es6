import Route from "@ember/routing/route";
import UserPayment from "discourse/plugins/discourse-subscriptions/discourse/models/user-payment";

export default Route.extend({
  templateName: "user/billing/payments",

  model() {
    return UserPayment.findAll();
  }
});
