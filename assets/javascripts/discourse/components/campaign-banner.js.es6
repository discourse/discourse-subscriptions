import { action } from "@ember/object";
import Component from "@ember/component";
import discourseComputed, { observes } from "discourse-common/utils/decorators";
import { inject as service } from "@ember/service";
import User from "discourse/models/user";
import { Promise } from "rsvp";

export default Component.extend({
  router: service(),
  dismissed: false,
  loading: false,
  showContributors: false,
  contributors: [],
  classNameBindings: [
    "isSidebar:campaign-banner-sidebar",
    "shouldShow:campaign-banner",
  ],

  init() {
    this._super(...arguments);
    const dismissed = document.cookie.includes(
      "discourse-subscriptions-campaign-banner-dismissed"
    );
    this.set("dismissed", dismissed);

    const contributorSetting = this.siteSettings
      .discourse_subscriptions_campaign_contributors;

    if (contributorSetting && contributorSetting !== "") {
      this.set("loading", true);
      let promises = [];
      const contributorNames = [...new Set(contributorSetting.split(","))];

      contributorNames.map((username) => {
        let promise = User.findByUsername(username).then((result) => {
          this.contributors.pushObject(result);
        });

        promises.push(promise);
      });

      Promise.all(promises).then(() => {
        this.set("showContributors", true);
        this.set("loading", false);
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
    "dismissed"
  )
  shouldShow(currentRoute, currentUser, enabled, dismissed) {
    // do not show on admin or subscriptions pages
    const showOnRoute =
      currentRoute !== "discovery.s" &&
      !currentRoute.split(".")[0].includes("admin") &&
      currentRoute.split(".")[0] !== "s";

    return showOnRoute && currentUser && enabled && !dismissed;
  },

  @observes("dismissed")
  _updateBodyClasses() {
    if (this.dismissed) {
      document.body.classList.remove("subscription-campaign-sidebar");
    }
  },

  @discourseComputed(
    "siteSettings.discourse_subscriptions_campaign_banner_location"
  )
  isSidebar(sidebarSetting) {
    return sidebarSetting === "Sidebar";
  },

  @discourseComputed
  subscriberGoal() {
    return (
      this.siteSettings.discourse_subscriptions_campaign_type === "Subscribers"
    );
  },

  @discourseComputed
  subscribers() {
    return this.siteSettings.discourse_subscriptions_campaign_subscribers;
  },

  @discourseComputed
  amountRaised() {
    return (
      this.siteSettings.discourse_subscriptions_campaign_amount_raised / 100
    );
  },

  @discourseComputed
  currency() {
    return this.siteSettings.discourse_subscriptions_currency;
  },

  @discourseComputed
  goalTarget() {
    return this.siteSettings.discourse_subscriptions_campaign_goal;
  },

  @discourseComputed
  isGoalMet() {
    const currentVolume = this.subscriberGoal
      ? this.subscribers
      : this.amountRaised;

    return currentVolume >= this.goalTarget;
  },

  @discourseComputed("currentUser")
  users(user) {
    return user;
  },

  @discourseComputed
  product() {
    return this.siteSettings.discourse_subscriptions_campaign_product;
  },

  @action
  dismissBanner() {
    let now = new Date();
    now.setMonth(now.getMonth() + 3);
    document.cookie = `name=discourse-subscriptions-campaign-banner-dismissed; expires=${now.toUTCString()};`;
    this.set("dismissed", true);
  },
});
