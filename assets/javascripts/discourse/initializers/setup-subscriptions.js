import { withPluginApi } from "discourse/lib/plugin-api";
import I18n from "I18n";

export default {
  name: "setup-subscriptions",
  initialize(container) {
    withPluginApi("0.8.11", (api) => {
      const siteSettings = container.lookup("service:site-settings");
      const isNavLinkEnabled =
        siteSettings.discourse_subscriptions_extra_nav_subscribe;
      if (isNavLinkEnabled) {
        api.addNavigationBarItem({
          name: "subscribe",
          displayName: I18n.t("discourse_subscriptions.navigation.subscribe"),
          href: "/subscriptions",
        });
      }

      const user = api.getCurrentUser();
      if (user) {
        api.addQuickAccessProfileItem({
          icon: "far-credit-card",
          href: `/u/${user.username}/billing/subscriptions`,
          content: "Billing",
        });
        
        if(user.admin){
          api.modifyClassStatic('model:site-setting', {
               pluginId: 'discourse-subscriptions',
               update(key, value, opts = {}) {
                if(key ==="discourse_subscriptions_pricing_table"){
                  const inputString = value;
                  // Extract pricing-table-id
                  const pricingTableIdRegex = /pricing-table-id="([^"]+)"/;
                  const pricingTableIdMatch = inputString.match(pricingTableIdRegex);
                  const pricingTableId = pricingTableIdMatch ? pricingTableIdMatch[1] : null;
      
                  // Extract publishable-key
                  const publishableKeyRegex = /publishable-key="([^"]+)"/;
                  const publishableKeyMatch = inputString.match(publishableKeyRegex);
                  const publishableKey = publishableKeyMatch ? publishableKeyMatch[1] : null;
                  if(pricingTableId && publishableKey){
                    value = JSON.stringify({pricingTableId,publishableKey})
                  }
                }
                this._super(key, value, opts);
              }
             });
        }
      }
    });
  },
};
