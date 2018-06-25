export default Ember.Component.extend({
  classNames: 'donation-list',
  hasSubscriptions: Ember.computed.notEmpty('subscriptions'),
  hasCharges: Ember.computed.notEmpty('charges')
})
