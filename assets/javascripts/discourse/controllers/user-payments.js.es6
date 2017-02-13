export default Ember.Controller.extend({
  user: Ember.inject.controller(),
  username: Ember.computed.alias('user.model.username_lower'),
  email: Ember.computed.alias('user.model.email'),

  actions: {
    choiceTest: function() {
      this.set('saved', true);
    }
  }
});
