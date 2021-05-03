import Campaign from "discourse/plugins/discourse-subscriptions/discourse/models/campaign";
import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  init() {
    this._super(...arguments);

    this.set("loading", true);
    Campaign.getInfo().then((result) => {
      this.set("campaign", result);
      this.set("loading", false);
    });
  },

  @discourseComputed
  goalTarget() {
    return this.siteSettings.discourse_subscriptions_campaign_goal;
  },
});
