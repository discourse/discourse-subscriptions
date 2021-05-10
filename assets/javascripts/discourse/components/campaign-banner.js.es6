import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  @discourseComputed
  goalTarget() {
    return this.siteSettings.discourse_subscriptions_campaign_goal;
  },

  @discourseComputed()
  isGoalMet() {
    const currentVolume = this.siteSettings.discourse_subscriptions_campaign_subscribers;

    return currentVolume >= this.goalTarget;
  },
});
