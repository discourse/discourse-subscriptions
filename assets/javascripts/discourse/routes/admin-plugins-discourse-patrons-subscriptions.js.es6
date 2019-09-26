import { ajax } from "discourse/lib/ajax";

export default Discourse.Route.extend({
  model() {
    return ajax("/patrons/admin/subscriptions", { method: "get" });
  }
});
