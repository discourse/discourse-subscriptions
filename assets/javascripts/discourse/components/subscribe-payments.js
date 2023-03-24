import Transaction from "discourse/plugins/discourse-subscriptions/discourse/models/transaction";
import Subscription from "discourse/plugins/discourse-subscriptions/discourse/models/subscription";
import Component from "@ember/component";
import { observes } from "discourse-common/utils/decorators";
import { inject as service } from "@ember/service";

export default Component.extend({
  dialog: service(),

  @observes("selectedPlan", "plans")
  setupButtonElement() {
    const plan = this.plans
      .filterBy("id", this.selectedPlan)
      .get("firstObject");
      console.log("plan")
      console.log(plan)

    if (!plan) {
      this.alert("plans.validate.payment_options.required");
      return;
    }

    if (this.selectedPlan) {
      const elements = this.stripe.elements();
      const paymentRequest = this.stripe.paymentRequest({
        currency: "usd",
        country: "US",
        requestPayerName: true,
        requestPayerEmail: true,
        total: {
          label: plan.subscriptionRate,
          amount: plan.unit_amount,
        },
      });
      this.set("buttonElement",
        elements.create('paymentRequestButton', {
          paymentRequest: paymentRequest,
        })
      );
      this.set("paymentRequest", paymentRequest);
    }

    this.paymentRequest.canMakePayment().then((result) => {
      if (result) {
        // mount the element
        this.buttonElement.mount("#payment-request-button");
      } else {
        //hide the button
        // document.getElementById("payment-request-button").style.display = "none";
        console.log("GooglePay and ApplePay is unvailable");
      }
    });

    this.paymentRequest.on('token', (result) => {
      console.log("this.paymentRequest.on('token', (result)", result);
      const subscription = Subscription.create({
          source: result.token.id,
          plan: plan.get("id"),
          promo: this.promoCode,
      });
  
      console.log("subscription", subscription);
      console.log("tokenid",result.token.id);
      console.log("planid",plan.get("id"));
      console.log("promocode",this.promoCode);
  
  
      subscription.save().then(save => {
          console.log("on subscription.save() Result: ", save);
          if (save.error) {
              this.dialog.alert(save.error.message || save.error);
              console.log("ERROR");
          } else {
              // save.complete('success');
              console.log("COMPLETED");
          }
      });
  
      result.complete('success');
      this._advanceSuccessfulTransaction(plan);
    });
  },

  didInsertElement() {
    this._super(...arguments);
  },
});
