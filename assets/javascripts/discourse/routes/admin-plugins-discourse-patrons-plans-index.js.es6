import { ajax } from "discourse/lib/ajax";

export default Discourse.Route.extend({
  model() {
    return ajax("/patrons/admin/plans", { method: "get" });
  }
});
