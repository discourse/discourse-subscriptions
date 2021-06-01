import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { equal } from "@ember/object/computed";
import { setting } from "discourse/lib/computed";
import Component from "@ember/component";
import discourseComputed, { observes } from "discourse-common/utils/decorators";
import { inject as service } from "@ember/service";

export default Component.extend({
  router: service(),
  dismissed: false,
  loading: false,
  isSidebar: equal(
    "siteSettings.discourse_subscriptions_campaign_banner_location",
    "Sidebar"
  ),
  subscribers: setting("discourse_subscriptions_campaign_subscribers"),
  subscriberGoal: equal(
    "siteSettings.discourse_subscriptions_campaign_type",
    "Subscribers"
  ),
  currency: setting("discourse_subscriptions_currency"),
  goalTarget: setting("discourse_subscriptions_campaign_goal"),
  product: setting("discourse_subscriptions_campaign_product"),
  showContributors: setting(
    "discourse_subscriptions_campaign_show_contributors"
  ),
  classNameBindings: [
    "isSidebar:campaign-banner-sidebar",
    "shouldShow:campaign-banner",
  ],

  init() {
    this._super(...arguments);

    this.set("contributors", []);

    if (this.showContributors) {
      return ajax("/s/contributors", { method: "get" }).then((result) => {
        this.setProperties({
          contributors: result,
          loading: false,
        });
      });
    }
  },

  didInsertElement() {
    this._super(...arguments);
    if (this.isSidebar && this.shouldShow) {
      document.body.classList.add("subscription-campaign-sidebar");
    } else {
      document.body.classList.remove("subscription-campaign-sidebar");
    }
  },

  @discourseComputed(
    "router.currentRouteName",
    "currentUser",
    "siteSettings.discourse_subscriptions_campaign_enabled",
    "visible"
  )
  shouldShow(currentRoute, currentUser, enabled, visible) {
    // do not show on admin or subscriptions pages
    const showOnRoute =
      currentRoute !== "discovery.s" &&
      !currentRoute.split(".")[0].includes("admin") &&
      currentRoute.split(".")[0] !== "s";

    return showOnRoute && currentUser && enabled && visible;
  },

  @observes("dismissed")
  _updateBodyClasses() {
    if (this.dismissed) {
      document.body.classList.remove("subscription-campaign-sidebar");
    }
  },

  @discourseComputed("dismissed")
  visible(dismissed) {
    const dismissedBannerKey = this.keyValueStore.get(
      "dismissed_campaign_banner"
    );
    const threeMonths = 2628000000 * 3;

    const bannerDismissedTime = new Date(dismissedBannerKey);
    const now = Date.now();

    return (
      (!dismissedBannerKey || now - bannerDismissedTime > threeMonths) &&
      !dismissed
    );
  },

  @discourseComputed
  amountRaised() {
    return (
      this.siteSettings.discourse_subscriptions_campaign_amount_raised / 100
    );
  },

  @discourseComputed
  isGoalMet() {
    const currentVolume = this.subscriberGoal
      ? this.subscribers
      : this.amountRaised;

    return currentVolume >= this.goalTarget;
  },

  @action
  dismissBanner() {
    this.set("dismissed", true);
    this.keyValueStore.set({
      key: "dismissed_campaign_banner",
      value: Date.now(),
    });
  },
});
