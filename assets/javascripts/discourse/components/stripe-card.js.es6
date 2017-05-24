import { ajax } from 'discourse/lib/ajax';
import { getRegister } from 'discourse-common/lib/get-owner';

const { computed: { alias }, observer } = Ember

export default Ember.Component.extend({

  routing: Ember.inject.service('-routing'),
  params: alias('routing.router.currentState.routerJsState.fullQueryParams'),

  donateAmounts: [
    { value: 'consumer-defender-1', name: 'Consumer Defender: $1.00'},
    { value: 'consumer-defender-2', name: 'Consumer Defender: $2.00'},
    { value: 'consumer-defender-5', name: 'Consumer Defender: $5.00'},
//    { value: 10, name: '$10.00'},
//    { value: 20, name: '$20.00'},
//    { value: 50, name: '$50.00'}
  ],
  result: [],
  amount: null,
  stripe: null,
  transactionInProgress: null,
  settings: null,

  consumerDefenderWithMembership: function() {
    return this.get('params.plan') == 'consumer-defender-with-membership';
  }.property('params'),

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
            email: self.get('email'),
            username: self.get('username'),
            create_account: self.get('create_accounts')
          };

          if(this.get('params.plan')) {
            params.plan = this.get('params.plan');
          }
          else {
            params.amount = self.get('amount') * 100;
          }

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
