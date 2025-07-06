import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import AdminCancelSubscription from "discourse/plugins/discourse-subscriptions/discourse/components/modal/admin-cancel-subscription";
import { i18n } from "discourse-i18n";
import { ajax } from "discourse/lib/ajax";
import AdminSubscription from "../models/admin-subscription";
import User from "discourse/models/user";

export default class AdminPluginsDiscourseSubscriptionsSubscriptionsController extends Controller {
  @service modal;
  @service dialog;
  @service router;

  @tracked subscriptions = [];
  @tracked meta = null;
  @tracked isLoadingMore = false;

  @action
  loadMore() {
    if (this.isLoadingMore || !this.meta?.more) {
      return;
    }

    this.isLoadingMore = true;

    ajax("/s/admin/subscriptions.json", {
      method: "GET",
      data: { offset: this.meta.offset },
    })
      .then((result) => {
        const newSubscriptions = result.subscriptions.map((s) => {
          if (s.user) {
            s.user = User.create(s.user);
          }
          return AdminSubscription.create(s);
        });

        this.subscriptions.pushObjects(newSubscriptions);
        this.set("meta", result.meta);
      })
      .finally(() => {
        this.isLoadingMore = false;
      });
  }
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
    const closeModal = model.closeModal;

    subscription.loading = true;

    subscription
      .destroy()
      .then(() => {
        this.dialog.alert(i18n("discourse_subscriptions.admin.canceled"));
        this.router.refresh();
      })
      .catch((data) => this.dialog.alert(data.jqXHR.responseJSON.errors.join("\n")))
      .finally(() => {
        subscription.loading = false;
        if (closeModal) {
          closeModal();
        }
      });
  }

  @action
  revokeAccess(subscription) {
    this.dialog.yesNoConfirm({
      message: "Are you sure you want to revoke this user's access immediately? This cannot be undone.",
      didConfirm: () => {
        subscription.loading = true;

        ajax(`/s/admin/subscriptions/${subscription.id}/revoke`, {
          method: "POST",
        })
          .then(() => {
            this.dialog.alert("Access has been revoked.");
            this.router.refresh();
          })
          .catch((err) => this.dialog.alert(err.jqXHR.responseJSON.errors[0]))
          .finally(() => {
            subscription.loading = false;
          });
      },
    });
  }
}
