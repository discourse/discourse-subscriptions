import { ajax } from 'discourse/lib/ajax';
import { getRegister } from 'discourse-common/lib/get-owner';

export default Ember.Component.extend({
  donateAmounts: [
    { value: 1, name: '1.00'},
    { value: 2, name: '2.00'},
    { value: 5, name: '5.00'},
    { value: 10, name: '10.00'},
    { value: 20, name: '20.00'},
    { value: 50, name: '50.00'}
  ],
  result: [],
  amount: null,
  stripe: null,
  transactionInProgress: null,
  settings: null,

  init() {
    this._super();
    this.set('anon', (Discourse.User.current() == null));
    this.set('settings', getRegister(this).lookup('site-settings:main'));
    this.set('create_accounts', this.get('anon') && this.get('settings').discourse_donations_enable_create_accounts);
    this.set('stripe', Stripe(this.get('settings').discourse_donations_public_key));
  },

  card: function() {
    let elements = this.get('stripe').elements();
    return elements.create('card', {
      hidePostalCode: !this.get('settings').discourse_donations_zip_code
    });
  }.property('stripe'),

  didInsertElement() {
    this._super();
    this.get('card').mount('#card-element');
  },

  setSuccess() {
    this.set('paymentSuccess', true);
  },

  endTranscation() {
    this.set('transactionInProgress', false);
  },

  concatMessages(messages) {
    this.set('result', this.get('result').concat(messages));
  },

  actions: {
    submitStripeCard() {
      let self = this;

      self.set('transactionInProgress', true);

      this.get('stripe').createToken(this.get('card')).then(data => {

        self.set('result', []);

        if (data.error) {
          self.set('result', data.error.message);
          self.endTranscation();
        }
        else {

          let params = {
            stripeToken: data.token.id,
            amount: self.get('amount') * 100,
            email: self.get('email'),
            username: self.get('username'),
            create_account: self.get('create_accounts')
          };

          if(!self.get('paymentSuccess')) {
            ajax('/charges', { data: params, method: 'post' }).then(data => {
              self.concatMessages(data.messages);
              self.endTranscation();
            });
          }
        }
      });
    }
  }
});
