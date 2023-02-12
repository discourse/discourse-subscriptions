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

    if (!plan) {
      this.alert("plans.validate.payment_options.required");
      return;
    }

    if (this.selectedPlan) {
      const elements = this.stripe.elements();
      const paymentRequest = this.stripe.paymentRequest({
        currency: plan.currency,
        country: "US",
        requestPayerName: true,
        requestPayerEmail: true,
        total: {
          label: plan.subscriptionRate,
          amount: plan.unit_amount,
        }
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
        document.getElementById("payment-request-button").style.display = "none";
        console.log("GooglePay and ApplePay is unvailable");
      }
    });

    this.paymentRequest.on('token', (result) => {
      console.log("on token result", result);
      const subscription = Subscription.create({
        source: result.token.id,
        plan: plan.get("id"),
        promo: this.promoCode,
      });

      this.set("transaction", subscription.save());
    });

    this.paymentRequest.on("paymentmethod", async (e) => {
      // create a payment intent on the server
      this.transaction
        .then((result) => {
          console.log("on paymentmethod transaction result", result);
          if (result.error) {
            this.dialog.alert(result.error.message || result.error);
          } else if (
            result.status === "incomplete" ||
            result.status === "open"
          ) {
            const transactionId = result.id;
            const planId = this.selectedPlan;
            this.handleAuthentication(plan, result).then(
              (authenticationResult) => {
                if (authenticationResult && !authenticationResult.error) {
                  return Transaction.finalize(transactionId, planId).then(
                    () => {
                      this.advanceSuccessfulTransaction(plan);
                      e.complete("success");
                      console.log(`Success: ${authenticationResult.paymentIntent.id}`);
                    }
                  );
                } else if (authenticationResult.error) {
                  console.log("Payment fail");
                  e.complete("fail");
                }
              }
            );
          } else {
            this.advanceSuccessfulTransaction(plan);
            e.complete("success");
            console.log(`Success`);
          }
        })
        .catch((result) => {
          e.complete("fail");
          console.log("Payment fail");
          this.dialog.alert(
            result.jqXHR.responseJSON?.errors[0] || result.errorThrown
          );
        });

      // confirm the payment on the client
      console.log(e);
    });
  },

  didInsertElement() {
    this._super(...arguments);
  },
});
