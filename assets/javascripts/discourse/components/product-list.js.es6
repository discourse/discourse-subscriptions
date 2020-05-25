import discourseComputed from "discourse-common/utils/decorators";
import User from "discourse/models/user";

export default Ember.Component.extend({
  @discourseComputed()
  currentUser() {
    return User.current();
  }
});
