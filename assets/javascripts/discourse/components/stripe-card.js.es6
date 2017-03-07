import { ajax } from 'discourse/lib/ajax';
import { getRegister } from 'discourse-common/lib/get-owner';

export default Ember.Component.extend({
  donateAmounts: [1, 5, 10, 25],
  result: null,
  amount: null,
  stripe: null,
  transactionInProgress: null,
  settings: null,

  init() {
    this._super();
    this.set('settings', getRegister(this).lookup('site-settings:main'));
    this.set('stripe', Stripe(this.get('settings').discourse_donations_public_key));
  },

  card: function() {
    var elements = this.get('stripe').elements();
    return elements.create('card', {
      hidePostalCode: this.get('settings').discourse_donations_hide_zip_code
    });
  }.property('stripe'),

  didInsertElement() {
    this._super();
    this.get('card').mount('#card-element');
  },

  actions: {
    submitStripeCard() {
      var self = this;

      this.get('stripe').createToken(this.get('card')).then(data => {

        self.set('result', null);

        if (data.error) {
          self.set('result', data.error.message);
        }
        else {
          self.set('transactionInProgress', true);

          var params = {
            stripeToken: data.token.id,
            amount: self.get('amount') * 100
          };

          ajax('/charges', { data: params, method: 'post' }).then(data => {
            self.set('transactionInProgress', false);
            self.set('result', data.outcome.seller_message);
          });
        }
      });
    }
  }
});
