import discourseComputed from "discourse-common/utils/decorators";
import User from "discourse/models/user";
import Component from "@ember/component";

export default Component.extend({
  @discourseComputed()
  isLoggedIn() {
    return User.current();
  }
});
