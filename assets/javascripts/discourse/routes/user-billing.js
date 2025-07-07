import Route from "@ember/routing/route";
import { service } from "@ember/service";

export default class UserBillingRoute extends Route {
  @service router; // Make sure the router is injected

  templateName = "user/billing";

  // --- START OF FIX ---
  // This hook restores the critical security check.
  setupController(controller, model) {
    super.setupController(controller, model);

    // Get the user model for the username in the URL
    const userInUrl = this.modelFor("user");

    // If the logged-in user's ID does not match the ID of the user in the URL,
    // redirect them to the user's public summary page.
    if (this.currentUser?.id !== userInUrl?.id) {
      this.router.replaceWith("user.summary", userInUrl.username);
    }
  }
  // --- END OF FIX ---
}
