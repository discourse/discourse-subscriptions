
export default Discourse.Route.extend({
  model() {
    return {};
  },

  setupController(controller, model) {
    if (this.currentUser.id !== this.modelFor("user").id) {
      this.replaceWith("userActivity");
    }
    else {
      controller.setProperties({ model });
    };
  }
});
