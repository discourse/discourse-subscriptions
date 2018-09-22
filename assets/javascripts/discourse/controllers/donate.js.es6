import { default as computed } from 'ember-addons/ember-computed-decorators';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import { ajax } from 'discourse/lib/ajax';
import { getOwner } from 'discourse-common/lib/get-owner';
import { emailValid } from "discourse/lib/utilities";

export default Ember.Controller.extend({
  loadingDonations: false,
  loadDonationsDisabled: Ember.computed.not('emailVaild'),

  @computed('charges.[]', 'subscriptions.[]')
  hasDonations(charges, subscriptions) {
    return (charges && charges.length > 0) ||
           (subscriptions && subscriptions.length > 0);
  },

  @computed('email')
  emailVaild(email) {
    return emailValid(email);
  },

  actions: {
    loadDonations() {
      let email = this.get('email');

      this.set('loadingDonations', true);

      ajax('/donate/charges', {
        data: { email },
        type: 'GET'
      }).then((result) => {
        this.setProperties({
          charges: Ember.A(result.charges),
          subscriptions: Ember.A(result.subscriptions),
          customer: result.customer
        });
      }).catch(popupAjaxError).finally(() => {
        this.setProperties({
          loadingDonations: false,
          hasEmailResult: true
        });

        Ember.run.later(() => {
          this.set('hasEmailResult', false);
        }, 6000);
      });
    },

    showLogin() {
      const controller = getOwner(this).lookup('route:application');
      controller.send('showLogin');
    }
  }
});
