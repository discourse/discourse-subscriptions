import { ajax } from 'discourse/lib/ajax';

export default Ember.Component.extend({
  result: null,
  stripe: Stripe('pk_test_b8RmhzlL8QPizJRqOrKF3JEV'),

  card: function() {
    var elements = this.get('stripe').elements();
    return elements.create('card', { hidePostalCode: true });
  }.property('stripe'),

  didInsertElement() {
    this._super();
    this.get('card').mount('#card-element');
  },

  actions: {
    submitStripeCard() {
      var self = this;

      this.get('stripe').createToken(this.get('card')).then(function(result) {

        self.set('result', null);

        if (result.error) {
          console.log('error yo');
        }
        else {
          var params = {
            stripeToken: result.token.id,
            amount: 1234
          };

          ajax('/charges', { data: params, method: 'post' }).then(data => {
            self.set('result', (data.status == 'succeeded' ? true : null));
          }).catch((data) => {
            console.log('catch', data);
          });
        }
      });
    }
  }
});
