import { ajax } from "discourse/lib/ajax";
import EmberObject from "@ember/object";

const Invoice = EmberObject.extend({});

Invoice.reopenClass({
  findAll() {
    return ajax("/s/invoices", { method: "get" }).then(result =>
      result.map(invoice => Invoice.create(invoice))
    );
  }
});

export default Invoice;
