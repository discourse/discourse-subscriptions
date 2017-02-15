import { ajax } from 'discourse/lib/ajax';

export default Ember.Controller.extend({
  user: Ember.inject.controller(),
  username: Ember.computed.alias('user.model.username_lower'),
  email: Ember.computed.alias('user.model.email'),

  actions: {
    makePayment: function() {

      ajax('/payments', { method: 'POST' }).then(() => {
        console.log(this);
      });

      this.set('saved', true);
    }
  }
});
