import { withPluginApi } from "discourse/lib/plugin-api";
import I18n from "I18n";

export default {
  name: "setup-subscriptions",
  initialize(container) {
    withPluginApi("0.8.11", api => {
      const siteSettings = container.lookup("site-settings:main");
      const isNavLinkEnabled =
        siteSettings.discourse_subscriptions_extra_nav_subscribe;
      if (isNavLinkEnabled) {
        api.addNavigationBarItem({
          name: "subscribe",
          displayName: I18n.t("discourse_subscriptions.navigation.subscribe"),
          href: "/s"
        });
      }
    });
  }
};
