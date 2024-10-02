import Route from "@ember/routing/route";
import { inject as service } from "@ember/service";

export default class SubscribeRoute extends Route {
  @service router;

  beforeModel() {
    const pricingTableEnabled =
      this.siteSettings.discourse_subscriptions_pricing_table_enabled;

    if (pricingTableEnabled) {
      this.router.transitionTo("subscriptions");
    }
  }
}
