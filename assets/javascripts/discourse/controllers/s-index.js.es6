import Controller from "@ember/controller";
import discourseComputed from "discourse-common/utils/decorators";
import User from "discourse/models/user";

export default Controller.extend({
  @discourseComputed()
  isLoggedIn() {
    return User.current();
  },
});
