import User from "discourse/models/user";

export default {
  shouldRender(args, component) {
    const { siteSettings } = component;
    const currentUser = User.current();
    const enabled = siteSettings.discourse_subscriptions_campaign_enabled;
    const dismissed = document.cookie.indexOf(
      "discourse-subscriptions-campaign-banner-dismissed"
    );

    // render unless:
    // - the user is not logged in
    // - the campaign is disabled
    // - the user has dismissed the banner
    return currentUser && enabled && dismissed === -1;
  },
};
