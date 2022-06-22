import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Controller.extend({
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
    const paymentMethodObject = await this.stripe.createPaymentMethod({
      type: "card",
      card: this.cardElement,
    });

    if (paymentMethodObject.error) {
      popupAjaxError(paymentMethodObject.error);
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
    }
  },
});
