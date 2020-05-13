import { withPluginApi } from "discourse/lib/plugin-api";

function initialize(api, container) {
  const siteSettings = api.container.lookup("site-settings:main");
  const isNavLinkEnabled =
    siteSettings.discourse_subscriptions_extra_nav_subscribe;
  if (isNavLinkEnabled) {
    api.addNavigationBarItem({
      name: "subscribe",
      displayName: "Subscribe",
      href: "/s"
    });
  }
}

export default {
  name: "setup-subscriptions",
  initialize(container) {
    withPluginApi("0.8.11", api => initialize(api, container));
  }
};
