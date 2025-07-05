import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import AdminCancelSubscription from "discourse/plugins/discourse-subscriptions/discourse/components/modal/admin-cancel-subscription";
import { i18n } from "discourse-i18n";
import { ajax } from "discourse/lib/ajax";

export default class AdminPluginsDiscourseSubscriptionsSubscriptionsController extends Controller {
  @service modal;
  @service dialog;
  @service router;

  // We need to make these properties tracked so the UI updates
  @tracked stripeSubscriptions = [];
  @tracked razorpayPurchases = [];

  @action
  showCancelModal(subscription) {
    this.modal.show(AdminCancelSubscription, {
      model: {
        subscription,
        cancelSubscription: this.cancelSubscription,
      },
    });
  }

  @action
  cancelSubscription(model) {
    const subscription = model.subscription;
    const refund = model.refund;
    const closeModal = model.closeModal;

    subscription.loading = true; // Use direct assignment

    subscription
      .destroy(refund)
      .then(() => {
        this.dialog.alert(i18n("discourse_subscriptions.admin.canceled"));
        this.router.refresh("adminPlugins.discourse-subscriptions.subscriptions");
      })
      .catch((data) => this.dialog.alert(data.jqXHR.responseJSON.errors.join("\n")))
      .finally(() => {
        subscription.loading = false; // Use direct assignment
        if (closeModal) {
          closeModal();
        }
      });
  }

  @action
  revokeRazorpayPurchase(purchase) {
    this.dialog.yesNoConfirm({
      message: "Are you sure you want to revoke this user's access immediately? This cannot be undone.",
      didConfirm: () => {
        // Create a new array with the updated item for reactivity
        this.razorpayPurchases = this.razorpayPurchases.map(p => {
          if (p.id === purchase.id) {
            return { ...p, loading: true };
          }
          return p;
        });

        ajax(`/s/admin/subscriptions/${purchase.id}/revoke`, {
          method: "POST",
        })
          .then(() => {
            this.dialog.alert("Access has been revoked.");
            this.router.refresh("adminPlugins.discourse-subscriptions.subscriptions");
          })
          .catch((err) => {
            let errorMessage = I18n.t("discourse_subscriptions.errors.unknown");
            if (err.jqXHR?.responseJSON?.errors?.length) {
              errorMessage = err.jqXHR.responseJSON.errors.join(", ");
            } else if (err.message) {
              errorMessage = err.message;
            }
            this.dialog.alert(errorMessage);
          })
          .finally(() => {
            this.razorpayPurchases = this.razorpayPurchases.map(p => {
              if (p.id === purchase.id) {
                return { ...p, loading: false };
              }
              return p;
            });
          });
      },
    });
  }
}
