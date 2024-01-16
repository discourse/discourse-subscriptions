import Controller from "@ember/controller";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from "I18n";

export default Controller.extend({
  loading: false,
  dialog: service(),

  @discourseComputed
  stripeConfigured() {
    return !!this.siteSettings.discourse_subscriptions_public_key;
  },

  @discourseComputed
  campaignEnabled() {
    return this.siteSettings.discourse_subscriptions_campaign_enabled;
  },

  @discourseComputed
  campaignProductSet() {
    return !!this.siteSettings.discourse_subscriptions_campaign_product;
  },

  @action
  triggerManualRefresh() {
    ajax(`/s/admin/refresh`, {
      method: "post",
    }).then(() => {
      this.dialog.alert(
        I18n.t("discourse_subscriptions.campaign.refresh_page")
      );
    });
  },

  @action
  createOneClickCampaign() {
    this.dialog.yesNoConfirm({
      title: I18n.t("discourse_subscriptions.campaign.confirm_creation_title"),
      message: htmlSafe(
        I18n.t("discourse_subscriptions.campaign.confirm_creation")
      ),
      didConfirm: () => {
        this.set("loading", true);

        ajax(`/s/admin/create-campaign`, {
          method: "post",
        })
          .then(() => {
            this.set("loading", false);
            this.dialog.confirm({
              message: I18n.t("discourse_subscriptions.campaign.created"),
              shouldDisplayCancel: false,
              didConfirm: () => this.send("showSettings"),
              didCancel: () => this.send("showSettings"),
            });
          })
          .catch(popupAjaxError);
      },
    });
  },
});
