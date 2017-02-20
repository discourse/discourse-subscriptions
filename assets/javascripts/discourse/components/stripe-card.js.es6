export default Ember.Component.extend({
  stripe: Stripe('pk_test_b8RmhzlL8QPizJRqOrKF3JEV'),
  card: function() {
    var elements = this.get('stripe').elements();
    return elements.create('card', { hidePostalCode: true });
  }.property('stripe'),

  didInsertElement() {
    this.get('card').mount('#stripe-card');
  },

  actions: {
    submitStripeCard() {
      this.get('stripe').createToken(this.get('card')).then(function(result) {
        if (result.error) {
          console.log('error yo');
        }
        else {
          var form = document.getElementById('stripe-card');
          var hiddenInput = document.createElement('input');
          // hiddenInput.setAttribute('type', 'hidden');
          hiddenInput.setAttribute('name', 'stripeToken');
          hiddenInput.setAttribute('value', result.token.id);
          form.appendChild(hiddenInput);
        }
      });
    }
  }
});
