import { action } from "@ember/object";
import Route from "@ember/routing/route";
import { service } from "@ember/service";

export default Route.extend({
  router: service(),

  @action
  showSettings() {
    const controller = this.controllerFor("adminSiteSettings");
    this.router
      .transitionTo("adminSiteSettingsCategory", "plugins")
      .then(() => {
        controller.set("filter", "plugin:discourse-subscriptions campaign");
        controller.set("_skipBounce", true);
        controller.filterContentNow("plugins");
      });
  },
});
