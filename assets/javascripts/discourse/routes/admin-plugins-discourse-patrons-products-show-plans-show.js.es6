import AdminPlan from "discourse/plugins/discourse-patrons/discourse/models/admin-plan";
import AdminProduct from "discourse/plugins/discourse-patrons/discourse/models/admin-product";

export default Discourse.Route.extend({
  model(params) {
    const id = params['plan-id'];
    const product = this.modelFor('adminPlugins.discourse-patrons.products.show').product;
    let plan;

    if(id === 'new') {
      plan = AdminPlan.create({ product: product.get('id') });
    }
    else {
      plan = AdminPlan.find(id);
    }

    return Ember.RSVP.hash({ plan, product });
  },

  renderTemplate(controller, model) {
    this.render('adminPlugins.discourse-patrons.products.show.plans.show', {
      into: 'adminPlugins.discourse-patrons.products',
      outlet: 'main',
      controller: 'adminPlugins.discourse-patrons.products.show.plans.show',
    });
  },
});
