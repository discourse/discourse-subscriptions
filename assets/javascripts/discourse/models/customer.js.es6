import { ajax } from "discourse/lib/ajax";
import EmberObject from "@ember/object";

const Customer = EmberObject.extend({
  save() {
    const data = {
      source: this.source,
    };

    return ajax("/s/customers", { method: "post", data });
  },
});

export default Customer;
