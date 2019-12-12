import { ajax } from "discourse/lib/ajax";

const Customer = Discourse.Model.extend({
  save() {
    const data = {
      source: this.source
    };

    return ajax("/s/customers", { method: "post", data });
  }
});

export default Customer;
