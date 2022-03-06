import Route from "@ember/routing/route";

export default Route.extend({
  templateName: "user/billing/index",

  redirect() {
    this.transitionTo("user.billing.subscriptions");
  },
});
