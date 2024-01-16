import Route from "@ember/routing/route";
import { inject as service } from "@ember/service";

export default Route.extend({
  router: service(),

  templateName: "user/billing",

  setupController(controller, model) {
    if (this.currentUser.id !== this.modelFor("user").id) {
      this.router.replaceWith("userActivity");
    } else {
      controller.setProperties({ model });
    }
  },
});
