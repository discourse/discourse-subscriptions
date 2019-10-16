import AdminProduct from "discourse/plugins/discourse-patrons/discourse/models/admin-product";
import Group from "discourse/models/group";

export default Discourse.Route.extend({
  model(params) {
    const id = params['product-id'];
    let product;

    if(id === 'new') {
      product = AdminProduct.create({ active: true, isNew: true });
    }
    else {
      product = AdminProduct.find(id);
    }

    const groups = Group.findAll({ ignore_automatic: true });

    return Ember.RSVP.hash({ product, groups });
  }
});
