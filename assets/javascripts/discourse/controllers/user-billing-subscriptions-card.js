import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import I18n from "I18n";
import bootbox from "bootbox";

export default Controller.extend({
  loading: false,
  init() {
    this._super(...arguments);
    this.set(
      "stripe",
      Stripe(this.siteSettings.discourse_subscriptions_public_key)
    );
    const elements = this.get("stripe").elements();
    this.set("cardElement", elements.create("card", { hidePostalCode: true }));
  },

  @action
  async updatePaymentMethod() {
    this.set("loading", true);
    const paymentMethodObject = await this.stripe.createPaymentMethod({
      type: "card",
      card: this.cardElement,
    });

    if (paymentMethodObject.error) {
      bootbox.alert(
        paymentMethodObject.error?.message || I18n.t("generic_error")
      );
      this.set("loading", false);
      return;
    }

    const paymentMethod = paymentMethodObject.paymentMethod.id;

    try {
      await ajax(`/s/user/subscriptions/${this.model}`, {
        method: "PUT",
        data: {
          payment_method: paymentMethod,
        },
      });
    } catch (err) {
      popupAjaxError(err);
    } finally {
      this.set("loading", false);
    }
  },
});
