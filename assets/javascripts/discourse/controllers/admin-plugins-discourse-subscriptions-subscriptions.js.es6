import { alias } from "@ember/object/computed";
import AdminSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/admin-subscription";
import Controller from "@ember/controller";
import showModal from "discourse/lib/show-modal";

export default Controller.extend({
  loading: false,
  canLoadMore: alias("model.has_more"),

  actions: {
    showCancelModal(subscription) {
      showModal("admin-cancel-subscription", {
        model: subscription,
      });
    },

    loadMore() {
      if (!this.loading && this.canLoadMore) {
        this.set("loading", true);

        AdminSubscription.loadMore(this.model.last_record).then((result) => {
          const updated = this.model.data.concat(result.data);
          this.set("model", result);
          this.set("model.data", updated);
          this.set("loading", false);
        });
      }
    },
  },
});
