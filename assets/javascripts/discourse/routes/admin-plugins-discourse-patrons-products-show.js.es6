import AdminProduct from "discourse/plugins/discourse-patrons/discourse/models/admin-plan";

export default Discourse.Route.extend({
  model() {
    return AdminProduct.create();
  }
});
