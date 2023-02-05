import Component from "@ember/component";

export default Component.extend({
  didInsertElement() {
    this._super(...arguments);
    this.paymentRequest.canMakePayment().then((result)=> {
      if(result) {
        // mount the element
        this.buttonElement.mount("#payment-request-button");
      } else {
        //hide the button
        document.getElementById("payment-request-button").style.display = "none";
        console.log("GooglePay is unvailable")
      }
    });
    this.setbuttonElementStyles();
    this.paymentRequest.on("paymentMethod", async (e) => {
      // create a payment intent on the server
      // confirm the payment on the client
      console.log(e);
    });
  },

  setbuttonElementStyles() {
    const root = document.querySelector(":root");
    const computedStyle = getComputedStyle(root);
    const primaryColor = computedStyle.getPropertyValue("--primary");
    const placeholderColor =
      computedStyle.getPropertyValue("--secondary-medium");
    this.buttonElement.update({
      style: {
        base: {
          color: primaryColor,
          "::placeholder": {
            color: placeholderColor,
          },
        },
      },
    });
  },
  didDestroyElement() {},
});
