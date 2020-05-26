import discourseComputed from "discourse-common/utils/decorators";
import User from "discourse/models/user";
import { isEmpty } from "@ember/utils";
import Component from "@ember/component";

export default Component.extend({
  @discourseComputed("products")
  emptyProducts(products) {
    return isEmpty(products);
  },

  @discourseComputed()
  isLoggedIn() {
    return User.current();
  }
});
