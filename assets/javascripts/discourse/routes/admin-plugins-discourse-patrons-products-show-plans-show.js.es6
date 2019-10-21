import AdminPlan from "discourse/plugins/discourse-patrons/discourse/models/admin-plan";
import AdminProduct from "discourse/plugins/discourse-patrons/discourse/models/admin-product";

export default Discourse.Route.extend({
  templateName: 'admin-plugins-discourse-patrons-plans-show',

  model(params) {
    console.log('product plans', params);

    // const id = params['plan-id'];
    // let plan;
    //
    // if(id === 'new') {
    //   plan = AdminPlan.create();
    // }
    // else {
    //   plan = AdminPlan.find(id);
    // }
    //
    // const products = AdminProduct.findAll();
    //
    // return Ember.RSVP.hash({ plan, products });
  }
});
