import Subscription from "discourse/plugins/discourse-patrons/discourse/models/subscription";

export default Discourse.Route.extend({
  model() {
    return Subscription.findAll();
  },

  setupController(controller, model) {
    if (this.currentUser.id !== this.modelFor("user").id) {
      this.replaceWith("userActivity");
    } else {
      controller.setProperties({ model });
    }
  }
});
