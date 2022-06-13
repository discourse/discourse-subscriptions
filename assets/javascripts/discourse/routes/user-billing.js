import Route from "@ember/routing/route";

export default Route.extend({
  templateName: "user/billing",

  setupController(controller, model) {
    if (
      this.currentUser.admin ||
      this.currentUser.id === this.modelFor("user").id
    ) {
      controller.setProperties({ model });
    } else {
      this.replaceWith("userActivity");
    }
  },
});
