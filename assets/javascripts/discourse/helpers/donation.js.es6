import { registerHelper } from "discourse-common/lib/helpers";
import { formatAnchor, formatAmount } from '../lib/donation-utilities';

registerHelper("donation-subscription", function([subscription]) {
  let currency = subscription.plan.currency.toUpperCase();
  let html = currency;

  html += ` ${formatAmount(subscription.plan.amount, currency)} `;

  html += I18n.t(`discourse_donations.period.${subscription.plan.interval}`, {
    anchor: formatAnchor(subscription.plan.interval, moment.unix(subscription.billing_cycle_anchor))
  });

  return new Handlebars.SafeString(html);
});

registerHelper("donation-invoice", function([invoice]) {
  let details = invoice.lines.data[0];
  let html = I18n.t('discourse_donations.invoice_prefix');
  let currency = details.currency.toUpperCase();

  html += ` ${currency}`;

  html += ` ${formatAmount(details.amount, currency)} `;

  html += I18n.t(`discourse_donations.period.once`, {
    anchor: formatAnchor('once', moment.unix(invoice.date))
  });

  if (invoice.invoice_pdf) {
    html += ` (<a href='${invoice.invoice_pdf}' target='_blank'>${I18n.t('discourse_donations.invoice')}</a>)`;
  }

  return new Handlebars.SafeString(html);
});

registerHelper("donation-charge", function([charge]) {
  let html = I18n.t('discourse_donations.invoice_prefix');
  let currency = charge.currency.toUpperCase();

  html += ` ${currency}`;

  html += ` ${formatAmount(charge.amount, currency)} `;

  html += I18n.t(`discourse_donations.period.once`, {
    anchor: formatAnchor('once', moment.unix(charge.created))
  });

  if (charge.receipt_email) {
    html += `. ${I18n.t('discourse_donations.receipt', {
      email: charge.receipt_email
    })}`;
  }

  return new Handlebars.SafeString(html);
});
