import Controller from "@ember/controller";
import discourseComputed from "discourse-common/utils/decorators";
import User from "discourse/models/user";
import cookie from "discourse/lib/cookie";
import DiscourseURL from "discourse/lib/url";

export default Controller.extend({
  @discourseComputed()
  isLoggedIn() {
    return User.current();
  },

  actions: {
    createAccount() {
      const destinationUrl = document.baseURI;
      cookie("destination_url", destinationUrl, { path: "/" });
      DiscourseURL.redirectTo("/login");
    },
  },
});
