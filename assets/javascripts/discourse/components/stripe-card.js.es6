import { ajax } from 'discourse/lib/ajax';
import { getRegister } from 'discourse-common/lib/get-owner';
import { formatAnchor, zeroDecimalCurrencies } from '../lib/donation-utilities';
import { default as computed } from 'ember-addons/ember-computed-decorators';
import { emailValid } from "discourse/lib/utilities";

export default Ember.Component.extend({
  result: [],
  stripe: null,
  transactionInProgress: null,
  settings: null,
  showTransactionFeeDescription: false,

  init() {
    this._super();
    const user = this.get('currentUser');
    const settings = Discourse.SiteSettings;

    this.set('create_accounts', !user && settings.discourse_donations_enable_create_accounts);
    this.set('stripe', Stripe(settings.discourse_donations_public_key));

    const types = settings.discourse_donations_types.split('|') || [];
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
    return I18n.t(`discourse_donations.period.${type}`, { anchor: formatAnchor(type) });
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
    let card = elements.create('card', {
      hidePostalCode: !Discourse.SiteSettings.discourse_donations_zip_code
    });

    card.addEventListener('change', (event) => {
      if (event.error) {
        this.set('stripeError', event.error.message);
      } else {
        this.set('stripeError', '');
      }

      if (event.elementType === 'card' && event.complete) {
        this.set('stripeReady', true);
      }
    });

    return card;
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

  @computed('email')
  emailValid(email) {
    return emailValid(email);
  },

  @computed('email', 'emailValid')
  showEmailError(email, emailValid) {
    return email && email.length > 3 && !emailValid;
  },

  @computed('currentUser', 'emailValid')
  userReady(currentUser, emailValid) {
    return currentUser || emailValid;
  },

  @computed('userReady', 'stripeReady')
  formIncomplete(userReady, stripeReady) {
    return !userReady || !stripeReady;
  },

  @computed('transactionInProgress', 'formIncomplete')
  disableSubmit(transactionInProgress, formIncomplete) {
    return transactionInProgress || formIncomplete;
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
      this.set('transactionInProgress', true);

      this.get('stripe').createToken(this.get('card')).then(data => {
        self.set('result', []);

        if (data.error) {
          this.setProperties({
            stripeError: data.error.message,
            stripeReady: false
          });
          self.endTranscation();
        } else {
          const settings = Discourse.SiteSettings;

          const transactionFeeEnabled = settings.discourse_donations_enable_transaction_fee;
          let amount = transactionFeeEnabled ? this.get('totalAmount') : this.get('amount');

          if (zeroDecimalCurrencies.indexOf(setting.discourse_donations_currency) === -1) {
            amount = amount * 100;
          }

          let params = {
            stripeToken: data.token.id,
            type: self.get('type'),
            amount,
            email: self.get('email'),
            username: self.get('username'),
            create_account: self.get('create_accounts')
          };

          if(!self.get('paymentSuccess')) {
            ajax('/donate/charges', { data: params, method: 'post' }).then(d => {
              let donation = d.donation;

              if (donation) {
                if (donation.object === 'subscription') {
                  let subscriptions = this.get('subscriptions') || [];
                  subscriptions.push(donation);
                  this.set('subscriptions', subscriptions);
                } else if (donation.object === 'charge') {
                  let charges = this.get('charges') || [];
                  charges.push(donation);
                  this.set('charges', charges);
                }
              }

              self.concatMessages(d.messages);
              self.endTranscation();
            });
          }
        }
      });
    }
  }
});
