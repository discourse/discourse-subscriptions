import computed from "ember-addons/ember-computed-decorators";
import User from "discourse/models/user";

export default Ember.Component.extend({
  @computed()
  currentUser() {
    return User.current();
  }
});
