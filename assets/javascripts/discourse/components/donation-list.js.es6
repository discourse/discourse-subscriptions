import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';

export default Ember.Component.extend({
  classNames: 'donation-list',
  hasSubscriptions: Ember.computed.notEmpty('subscriptions'),
  hasCharges: Ember.computed.notEmpty('charges')
})
