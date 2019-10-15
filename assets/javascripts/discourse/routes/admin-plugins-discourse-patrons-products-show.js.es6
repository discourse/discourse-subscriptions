import AdminProduct from "discourse/plugins/discourse-patrons/discourse/models/admin-product";
import Group from "discourse/models/group";

export default Discourse.Route.extend({
  model(param) {
    const product = AdminProduct.create();
    const groups = Group.findAll({ ignore_automatic: true });

    return Ember.RSVP.hash({ product, groups });
  }
});
