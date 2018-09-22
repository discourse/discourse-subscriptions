import { withPluginApi } from 'discourse/lib/plugin-api';

export default {
  name: 'donations-edits',
  initialize(container) {
    const siteSettings = container.lookup('site-settings:main');

    withPluginApi('0.8.12', api => {
      api.decorateCooked($post => {
        const $form = $post.find('.stripe-checkout');
        if ($form.length) {
          const $input = $form.find('input');
          var s = document.createElement('script');
          s.src = 'https://checkout.stripe.com/checkout.js';
          s.setAttribute('class', 'stripe-button');
          s.setAttribute('data-key', siteSettings.discourse_donations_public_key);
          s.setAttribute('data-amount', $input.attr('amount'));
          s.setAttribute('data-name', siteSettings.discourse_donations_shop_name);
          s.setAttribute('data-description', $form.attr('content'));
          s.setAttribute('data-image', $form.attr('image') || '');
          s.setAttribute('data-locale', 'auto');
          s.setAttribute('data-zip-code', siteSettings.discourse_donations_zip_code);
          s.setAttribute('data-billing-address', siteSettings.discourse_donations_billing_address);
          s.setAttribute('data-currency', siteSettings.discourse_donations_currency);
          $form.append(s);
        }
      });

      if (siteSettings.discourse_donations_cause_category) {
        api.decorateWidget('category-header-widget:after', helper => {
          helper.widget.appEvents.on('page:changed', () => {
            helper.widget.scheduleRerender();
          });
        });
      }
    });
  }
};
