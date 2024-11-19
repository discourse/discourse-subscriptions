import Controller from "@ember/controller";
import { computed } from "@ember/object";
import { htmlSafe } from "@ember/template";
import I18n from "I18n";

export default Controller.extend({
  init() {
    this._super(...arguments);
    if (this.currentUser) {
      this.currentUser
        .checkEmail()
        .then(() => this.set("email", this.currentUser.email));
    }
  },
  pricingTable: computed("email", function () {
    try {
      const pricingTableId =
        this.siteSettings.discourse_subscriptions_pricing_table_id;
      const publishableKey =
        this.siteSettings.discourse_subscriptions_public_key;
      const pricingTableEnabled =
        this.siteSettings.discourse_subscriptions_pricing_table_enabled;

      if (!pricingTableEnabled || !pricingTableId || !publishableKey) {
        throw new Error("Pricing table not configured");
      }

      if (this.currentUser) {
        return htmlSafe(`<stripe-pricing-table
                pricing-table-id="${pricingTableId}"
                publishable-key="${publishableKey}"
                customer-email="${this.email}"></stripe-pricing-table>`);
      } else {
        return htmlSafe(`<stripe-pricing-table
                pricing-table-id="${pricingTableId}"
                publishable-key="${publishableKey}"
                ></stripe-pricing-table>`);
      }
    } catch {
      return I18n.t("discourse_subscriptions.subscribe.no_products");
    }
  }),
});
