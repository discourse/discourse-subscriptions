import Route from "@ember/routing/route";
import { inject as service } from "@ember/service";

export default Route.extend({
  router: service(),
  templateName: "user/billing/index",

  redirect() {
    this.router.transitionTo("user.billing.subscriptions.index");
  },
});
