import DiscourseURL from "discourse/lib/url";

export default Ember.Controller.extend({
  redirect(product_id) {
    DiscourseURL.redirectTo(`/admin/plugins/discourse-patrons/products/${product_id}`);
  },

  actions: {
    cancelPlan(product_id) {
      this.redirect(product_id);
    },

    createPlan() {
      const product_id = this.get('model.plan.product');
      this.get('model.plan').save().then(() => this.redirect(product_id));
    }
  }
});
