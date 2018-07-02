import DiscourseRoute from "discourse/routes/discourse";
import DiscourseURL from 'discourse/lib/url';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import { ajax } from 'discourse/lib/ajax';

export default DiscourseRoute.extend({
  redirect() {
    if (!Discourse.SiteSettings.discourse_donations_enabled) {
      DiscourseURL.routeTo('/');
      return;
    }
  },

  setupController(controller) {
    let charges = [];
    let subscriptions = [];
    let customer = {};

    controller.set('loadingDonations', true);

    ajax('/donate/charges').then((result) => {
      if (result) {
        charges = result.charges;
        subscriptions = result.subscriptions;
        customer = result.customer;
      }

      controller.setProperties({
        charges: Ember.A(charges),
        subscriptions: Ember.A(subscriptions),
        customer
      });
    }).catch(popupAjaxError).finally(() => {
      controller.set('loadingDonations', false);
    });
  }
});
