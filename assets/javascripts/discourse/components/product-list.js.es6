import computed from "discourse-common/utils/decorators";
import User from "discourse/models/user";

export default Ember.Component.extend({
  @computed()
  currentUser() {
    return User.current();
  }
});
