import Transaction from "discourse/plugins/discourse-subscriptions/discourse/models/transaction";
import Subscription from "discourse/plugins/discourse-subscriptions/discourse/models/subscription";
import Component from "@ember/component";
import { observes } from "discourse-common/utils/decorators";
import { inject as service } from "@ember/service";
import { action } from '@ember/object';

export default Component.extend({
  dialog: service(),
  router: service(),

  @action
  redirectOnSuccess(result, plan) {
    result.complete('success')
    this.alert("plans.success");

    const location = plan.type === "recurring"
      ? "user.billing.subscriptions"
      : "user.billing.payments"
    const username = this.currentUser.username.toLowerCase();

    this.router.transitionTo(location, username);
  },

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
        this.buttonElement.mount("#payment-request-button");
      } else {
        //hide the button
        // document.getElementById("payment-request-button").style.display = "none";
        console.log("GooglePay and ApplePay is unvailable");
      }
    });

    this.paymentRequest.on('token', (result) => {
      const subscription = Subscription.create({
          source: result.token.id,
          plan: plan.get("id"),
          promo: this.promoCode,
      });

      subscription.save().then(save => {
        console.log(save)

        if (save.error) {
          this.dialog.alert(save.error.message || save.error);
        }
        else if (
          save.status === "incomplete" ||
          save.status === "open"
        ) {
          const transactionId = save.id;
          const planId = this.selectedPlan;
          this.handleAuthentication(plan, save).then(
            (authenticationResult) => {
              if (authenticationResult && !authenticationResult.error) {
                return Transaction.finalize(transactionId, planId).then(
                  () => {
                    this.send('redirectOnSuccess', result, plan);
                  }
                );
              }
            }
          );
        } else {
          this.send('redirectOnSuccess', result, plan);
        }
      })
        .catch((error) => {
        result.complete('fail');
        this.dialog.alert(
          error.jqXHR.responseJSON.errors[0] || error.errorThrown
        );
      });
    });
  },

  didInsertElement() {
    this._super(...arguments);
  },
});
