import Controller from "@ember/controller";
import showModal from "discourse/lib/show-modal";

export default Controller.extend({
  actions: {
    showCancelModal(subscription) {
      showModal("admin-cancel-subscription", {
        model: subscription,
      });
    },
  },
});
