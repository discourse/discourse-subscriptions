import { ajax } from "discourse/lib/ajax";

export default Discourse.Route.extend({
  model() {
    return ajax("/patrons/admin", {
      method: "get"
    })
      .then(results => {

        console.log(12, results);

        return results;
      });
  }
});
