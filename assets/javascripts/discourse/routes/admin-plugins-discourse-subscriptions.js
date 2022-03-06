import Route from "@ember/routing/route";
import { action } from "@ember/object";

export default Route.extend({
  @action
  showSettings() {
    const controller = this.controllerFor("adminSiteSettings");
    this.transitionTo("adminSiteSettingsCategory", "plugins").then(() => {
      controller.set("filter", "plugin:discourse-subscriptions campaign");
      controller.set("_skipBounce", true);
      controller.filterContentNow("plugins");
    });
  },
});
