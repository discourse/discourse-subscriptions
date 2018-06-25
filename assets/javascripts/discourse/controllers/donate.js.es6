import { default as computed } from 'ember-addons/ember-computed-decorators';

export default Ember.Controller.extend({
  loadingDonations: false,
  
  @computed('charges', 'subscriptions')
  hasDonations(charges, subscriptions) {
    return (charges && charges.length > 0) ||
           (subscriptions && subscriptions.length > 0);
  }
})
