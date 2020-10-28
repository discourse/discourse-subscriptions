import Component from "@ember/component";
import cookie from "discourse/lib/cookie";
import DiscourseURL from "discourse/lib/url";
import { default as getURL } from "discourse-common/lib/get-url";

export default Component.extend({
  classNames: ["login-required", "subscriptions"],
  actions: {
    createAccount() {
      const destinationUrl = window.location.href;
      const cookiePath = getURL("/");

      cookie("destination_url", destinationUrl, { path: cookiePath });
      DiscourseURL.redirectTo("/login");
    },
  },
});
