import AdminProduct from "discourse/plugins/discourse-patrons/discourse/models/admin-product";
import AdminPlan from "discourse/plugins/discourse-patrons/discourse/models/admin-plan";
import Group from "discourse/models/group";

export default Discourse.Route.extend({
  model(params) {
    console.log('products show', params);

    const product_id = params['product-id'];
    let product;
    let plans = [];

    if(product_id === 'new') {
      product = AdminProduct.create({ active: true, isNew: true });
    }
    else {
      product = AdminProduct.find(product_id);
      plans = AdminPlan.findAll({ product_id });
    }

    const groups = Group.findAll({ ignore_automatic: true });

    return Ember.RSVP.hash({ plans, product, groups });
  }
});
