import DiscourseURL from "discourse/lib/url";

export default Ember.Controller.extend({
  actions: {
    editProduct(id) {
      return DiscourseURL.redirectTo(
        `/admin/plugins/discourse-patrons/products/${id}`
      );
    }
  }
});
