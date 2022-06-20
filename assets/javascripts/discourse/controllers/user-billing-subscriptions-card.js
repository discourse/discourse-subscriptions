import Controller from "@ember/controller";

export default Controller.extend({
  init() {
    this._super(...arguments);
    this.set(
      "stripe",
      Stripe(this.siteSettings.discourse_subscriptions_public_key)
    );
    const elements = this.get("stripe").elements();
    this.set("cardElement", elements.create("card", { hidePostalCode: true }));
  }
});
