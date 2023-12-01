import Route from "@ember/routing/route";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";

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
