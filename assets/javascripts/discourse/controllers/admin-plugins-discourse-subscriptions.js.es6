import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import Controller from "@ember/controller";
import discourseComputed from "discourse-common/utils/decorators";
import getURL from "discourse-common/lib/get-url";
import I18n from "I18n";

export default Controller.extend({
  @discourseComputed
  campaignEnabled() {
    return this.siteSettings.discourse_subscriptions_campaign_enabled;
  },

  @action
  triggerManualRefresh() {
    ajax(`/s/admin/refresh`, {
      method: "post",
    }).then(() => {
      bootbox.alert(
        I18n.t("discourse_subscriptions.campaign.refresh_page"),
        () => {
          window.location.pathname = getURL(
            "/admin/plugins/discourse-subscriptions/products"
          );
        }
      );
    });
  },

  @action
  createOneClickCampaign() {
    ajax(`/s/admin/create-campaign`, {
      method: "post",
    }).then(() => {
      bootbox.alert(I18n.t("discourse_subscriptions.campaign.created"), () => {
        this.send("showSettings");
      });
    });
  },
});
