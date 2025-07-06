import Route from "@ember/routing/route";

export default class UserBillingRoute extends Route {
  templateName = "user/billing";

  // By removing the setupController hook, we let Discourse handle the
  // model and security checks, which is more reliable.
}
