import { ajax } from "discourse/lib/ajax";

export default Discourse.Route.extend({
  queryParams: {
    order: {
      refreshModel: true
    },
    ascending: {
      refreshModel: true
    }
  },

  model(params) {
    return ajax("/patrons/admin", {
      method: "get",
      data: {
        order: params.order,
        ascending: params.ascending
      }
    }).then(results => results);
  }
});
