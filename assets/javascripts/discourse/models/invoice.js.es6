import computed from "ember-addons/ember-computed-decorators";
import { ajax } from "discourse/lib/ajax";

const Invoice = Discourse.Model.extend({
  @computed("created")
  createdFormatted(created) {
    return moment.unix(created).format();
  }
});

Invoice.reopenClass({
  findAll() {
    return ajax("/patrons/invoices", { method: "get" }).then(result =>
      result.map(invoice => Invoice.create(invoice))
    );
  }
});

export default Invoice;
