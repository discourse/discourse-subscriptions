import Invoice from "discourse/plugins/discourse-patrons/discourse/models/invoice";

export default Discourse.Route.extend({
  model() {
    return Invoice.findAll();
  },

  setupController(controller, model) {
    if (this.currentUser.id !== this.modelFor("user").id) {
      this.replaceWith("userActivity");
    } else {
      controller.setProperties({ model });
    }
  }
});
