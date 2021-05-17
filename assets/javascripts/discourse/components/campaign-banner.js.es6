import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  classNameBindings: ['isSidebar:sidebar'],

  @discourseComputed
  isSidebar() {
    return this.siteSettings.discourse_subscriptions_campaign_banner_location === "Sidebar";
  },

  @discourseComputed
  subscriberGoal() {
    return this.siteSettings.discourse_subscriptions_campaign_type === "Subscribers";
  },

  @discourseComputed
  subscribers(){
    return this.siteSettings.discourse_subscriptions_campaign_subscribers;
  },

  @discourseComputed
  amountRaised(){
    return this.siteSettings.discourse_subscriptions_campaign_amount_raised / 100;
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
    const currentVolume = this.subscriberGoal ? this.subscribers : this.amountRaised;

    return currentVolume >= this.goalTarget;
  },
});
