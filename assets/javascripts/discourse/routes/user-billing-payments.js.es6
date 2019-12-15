import Route from "@ember/routing/route";
import Invoice from "discourse/plugins/discourse-subscriptions/discourse/models/invoice";

export default Route.extend({
  templateName: "user/billing/payments",

  model() {
    return Invoice.findAll();
  }
});
