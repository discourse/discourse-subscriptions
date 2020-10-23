import Component from "@ember/component";
import cookie from "discourse/lib/cookie";
import DiscourseURL from "discourse/lib/url";

export default Component.extend({
  classNames: ["login-required", "subscriptions"],
  actions: {
    createAccount() {
      const destinationUrl = document.baseURI;
      cookie("destination_url", destinationUrl, { path: "/" });
      DiscourseURL.redirectTo("/login");
    },
  },
});
