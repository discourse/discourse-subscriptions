import Component from "@ember/component";
import cookie from "discourse/lib/cookie";
import DiscourseURL from "discourse/lib/url";

export default Component.extend({
  classNames: ["login-required", "subscriptions"],
  actions: {
    createAccount() {
      const destinationUrl = document.baseURI;

      const pathRegEx = /(\/\w*)\/s.*$/g;
      const [pathMatch] = destinationUrl.matchAll(pathRegEx);
      const path = pathMatch ? pathMatch[1] : "/";
      cookie("destination_url", destinationUrl, { path: path });
      DiscourseURL.redirectTo("/login");
    },
  },
});
