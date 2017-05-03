import { ajax } from 'discourse/lib/ajax';
import { getRegister } from 'discourse-common/lib/get-owner';

export default Ember.Component.extend({
  donateAmounts: [
    { value: 1, name: '$1.00'},
    { value: 2, name: '$2.00'},
    { value: 5, name: '$5.00'},
    { value: 10, name: '$10.00'},
    { value: 20, name: '$20.00'},
    { value: 50, name: '$50.00'}
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
      hidePostalCode: this.get('settings').discourse_donations_hide_zip_code
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

  createUser() {
    let self = this;
    ajax('/users/hp', { method: 'get' }).then(data => {
      let params = {
        email: self.get('email'),
        username: self.get('username'),
        name: self.get('name'),
        password: self.get('password'),
        password_confirmation: data.value,
        challenge: data.challenge.split('').reverse().join(''),
      };

      ajax('/users', { data: params, method: 'post' }).then(data => {
        self.setSuccess();
        self.concatMessages(data.messages);
        self.endTranscation();
      });
    });
  },

  actions: {
    submitStripeCard() {
      let self = this;

      this.get('stripe').createToken(this.get('card')).then(data => {

        self.set('result', []);

        if (data.error) {
          self.set('result', data.error.message);
        }
        else {
          self.set('transactionInProgress', true);

          let params = {
            stripeToken: data.token.id,
            amount: self.get('amount') * 100,
            email: self.get('email'),
            username: self.get('username'),
            create_account: this.get('create_accounts')
          };

          if(!self.get('paymentSuccess')) {
            ajax('/charges', { data: params, method: 'post' }).then(data => {
              self.concatMessages(data.messages);

              if(!this.get('create_accounts')) {
                if(data.status == 'succeeded') { this.setSuccess() };
                self.endTranscation();
              }
              else {
                if(data.status == 'succeeded') {
                  this.createUser();
                }
                else {
                  self.endTranscation();
                }
              }
            });
          }
          else if (this.get('create_accounts')) {
            self.set('result', []);
            self.createUser();
          }
        }
      });
    }
  }
});
