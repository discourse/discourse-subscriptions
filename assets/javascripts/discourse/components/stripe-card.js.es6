import { ajax } from 'discourse/lib/ajax';

export default Ember.Component.extend({
  stripe: Stripe('pk_test_b8RmhzlL8QPizJRqOrKF3JEV'),

  card: function() {
    var elements = this.get('stripe').elements();
    return elements.create('card', { hidePostalCode: true });
  }.property('stripe'),

  didInsertElement() {
    this.get('card').mount('#card-element');
  },

  actions: {
    submitStripeCard() {
      this.get('stripe').createToken(this.get('card')).then(function(result) {
        if (result.error) {
          console.log('error yo');
        }
        else {
          var data = {
            stripeToken: result.token.id,
            amount: 1234
          };

          ajax('/charges', { data: data, method: 'post' }).then(data => {
            console.log(data);
          });
        }
      });
    }
  }
});
