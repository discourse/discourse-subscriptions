import Route from "@ember/routing/route";
import { ajax } from "discourse/lib/ajax";

export default Route.extend({
  queryParams: {
    order: {
      refreshModel: true,
    },
    descending: {
      refreshModel: true,
    },
  },

  model(params) {
    return ajax("/patrons/admin", {
      method: "get",
      data: {
        order: params.order,
        descending: params.descending,
      },
    }).then((results) => results);
  },
});
