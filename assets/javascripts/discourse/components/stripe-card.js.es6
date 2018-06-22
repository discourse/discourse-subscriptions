import { ajax } from 'discourse/lib/ajax';
import { getRegister } from 'discourse-common/lib/get-owner';
import { default as computed } from 'ember-addons/ember-computed-decorators';

export default Ember.Component.extend({
  result: [],
  stripe: null,
  transactionInProgress: null,
  settings: null,
  showTransactionFeeDescription: false,

  init() {
    this._super();
    this.set('anon', (!Discourse.User.current()));
    this.set('settings', getRegister(this).lookup('site-settings:main'));
    this.set('create_accounts', this.get('anon') && this.get('settings').discourse_donations_enable_create_accounts);
    this.set('stripe', Stripe(this.get('settings').discourse_donations_public_key));

    const types = Discourse.SiteSettings.discourse_donations_types.split('|') || [];
    const amounts = this.get('donateAmounts');

    this.setProperties({
      types,
      type: types[0],
      amount: amounts[0].value
    });
  },

  @computed('types')
  donationTypes(types) {
    return types.map((type) => {
      return {
        id: type,
        name: I18n.t(`discourse_donations.types.${type}`)
      }
    })
  },

  @computed('type')
  period(type) {
    let anchor;

    if (type === 'weekly') {
      anchor = moment().format('dddd');
    }

    if (type === 'monthly') {
      anchor = moment().format('Do');
    }

    if (type === 'yearly') {
      anchor = moment().format('MMMM D');
    }

    return I18n.t(`discourse_donations.period.${type}`, { anchor });
  },

  @computed
  donateAmounts() {
    const setting = Discourse.SiteSettings.discourse_donations_amounts.split('|');
    if (setting.length) {
      return setting.map((amount) => {
        return {
          value: parseInt(amount, 10),
          name: `${amount}.00`
        };
      });
    } else {
      return [];
    }
  },

  @computed('stripe')
  card(stripe) {
    let elements = stripe.elements();
    return elements.create('card', {
      hidePostalCode: !this.get('settings').discourse_donations_zip_code
    });
  },

  @computed('amount')
  transactionFee(amount) {
    const fixed = Discourse.SiteSettings.discourse_donations_transaction_fee_fixed;
    const percent = Discourse.SiteSettings.discourse_donations_transaction_fee_percent;
    const fee = ((amount + fixed)  /  (1 - percent)) - amount;
    return Math.round(fee * 100) / 100;
  },

  @computed('amount', 'transactionFee', 'includeTransactionFee')
  totalAmount(amount, fee, include) {
    if (include) return amount + fee;
    return amount;
  },

  didInsertElement() {
    this._super();
    this.get('card').mount('#card-element');
    Ember.$(document).on('click', Ember.run.bind(this, this.documentClick));
  },

  willDestroyElement() {
    Ember.$(document).off('click', Ember.run.bind(this, this.documentClick));
  },

  documentClick(e) {
    let $element = this.$('.transaction-fee-description');
    let $target = $(e.target);
    if ($target.closest($element).length < 1 &&
        this._state !== 'destroying') {
      this.set('showTransactionFeeDescription', false);
    }
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
    toggleTransactionFeeDescription() {
      this.toggleProperty('showTransactionFeeDescription');
    },

    submitStripeCard() {
      let self = this;
      self.set('transactionInProgress', true);
      this.get('stripe').createToken(this.get('card')).then(data => {
        self.set('result', []);

        if (data.error) {
          self.set('result', data.error.message);
          self.endTranscation();
        } else {
          const transactionFeeEnabled = Discourse.SiteSettings.discourse_donations_enable_transaction_fee;
          const amount = transactionFeeEnabled ? this.get('totalAmount') : this.get('amount');
          let params = {
            stripeToken: data.token.id,
            type: self.get('type'),
            amount: amount * 100,
            email: self.get('email'),
            username: self.get('username'),
            create_account: self.get('create_accounts')
          };

          if(!self.get('paymentSuccess')) {
            ajax('/charges', { data: params, method: 'post' }).then(d => {
              self.concatMessages(d.messages);
              self.endTranscation();
            });
          }
        }
      });
    }
  }
});
