export default Ember.Controller.extend({
  actions: {
    stripePaymentHandler(/* data */) {
      // console.log('stripePaymentHandler', data);
    },

    paymentSuccessHandler(/* paymentIntentId */) {
      // console.log('paymentSuccessHandler');
    }
  }
});
