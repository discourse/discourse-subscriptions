import AdminPlan from "discourse/plugins/discourse-patrons/discourse/models/admin-plan";
import AdminProduct from "discourse/plugins/discourse-patrons/discourse/models/admin-product";

export default Discourse.Route.extend({
  model() {
    const plan = AdminPlan.create();
    const products = AdminProduct.findAll();

    return Ember.RSVP.hash({ plan, products });
  }
});
