import AdminCancelSubscription from "../components/modal/admin-cancel-subscription";
import AdminSubscription from "../models/admin-subscription";
import Controller from "@ember/controller";
import { inject as service } from "@ember/service";

export default Controller.extend({
  modal: service(),
  loading: false,

  actions: {
    showCancelModal(subscription) {
      this.modal.show(AdminCancelSubscription, {
        model: {
          subscription,
        },
      });
    },

    loadMore() {
      if (!this.loading && this.model.has_more) {
        this.set("loading", true);

        return AdminSubscription.loadMore(this.model.last_record).then(
          (result) => {
            const updated = this.model.data.concat(result.data);
            this.set("model", result);
            this.set("model.data", updated);
            this.set("loading", false);
          }
        );
      }
    },
  },
});
