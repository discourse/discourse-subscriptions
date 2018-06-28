import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import { formatAnchor, formatAmount } from '../lib/donation-utilities';
import { default as computed, observes, on } from 'ember-addons/ember-computed-decorators';
import showModal from "discourse/lib/show-modal";

export default Ember.Component.extend({
  classNameBindings: [':donation-row', 'canceled', 'updating'],
  includePrefix: Ember.computed.or('invoice', 'charge'),
  canceled: Ember.computed.equal('subscription.status', 'canceled'),

  @computed('subscription', 'invoice', 'charge', 'customer')
  data(subscription, invoice, charge, customer) {
    if (subscription) {
      return $.extend({}, subscription.plan, {
        anchor: subscription.billing_cycle_anchor
      });
    } else if (invoice) {
      let receiptSent = false;

      if (invoice.receipt_number && customer.email) {
        receiptSent = true;
      }

      return $.extend({}, invoice.lines.data[0], {
        anchor: invoice.date,
        invoiceLink: invoice.invoice_pdf,
        receiptSent
      });
    } else if (charge) {
      let receiptSent = false;

      if (charge.receipt_number && charge.receipt_email) {
        receiptSent = true;
      }

      return $.extend({}, charge, {
        anchor: charge.created,
        receiptSent
      });
    }
  },

  @computed('data.currency')
  currency(currency) {
    return currency ? currency.toUpperCase() : null;
  },

  @computed('data.amount', 'currency')
  amount(amount, currency) {
    return formatAmount(amount, currency);
  },

  @computed('data.interval')
  interval(interval) {
    return interval || 'once';
  },

  @computed('data.anchor', 'interval')
  period(anchor, interval) {
    return I18n.t(`discourse_donations.period.${interval}`, {
      anchor: formatAnchor(interval, moment.unix(anchor))
    })
  },

  cancelSubscription() {
    const subscriptionId = this.get('subscription.id');
    this.set('updating', true);

    ajax('/donate/charges/cancel-subscription', {
      data: {
        subscription_id: subscriptionId
      },
      method: 'put'
    }).then(result => {
      if (result.success) {
        this.set('subscription', result.subscription);
      }
    }).catch(popupAjaxError).finally(() => {
      this.set('updating', false);
    });
  },

  actions: {
    cancelSubscription() {
      showModal('cancel-subscription', {
        model: {
          currency: this.get('currency'),
          amount: this.get('amount'),
          period: this.get('period'),
          confirm: () => this.cancelSubscription()
        }
      });
    }
  }
})
