import { ajax } from 'discourse/lib/ajax';
import { getRegister } from 'discourse-common/lib/get-owner';

export default Ember.Component.extend({
  donateAmounts: [1, 5, 10, 25],
  result: null,
  amount: null,
  stripe: null,

  init() {
    this._super();
    var public_key = getRegister(this).lookup('site-settings:main').discourse_donations_public_key
    this.set('stripe', Stripe(public_key));
  },

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
            amount: self.get('amount') * 100
          };

          console.log(params);

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
