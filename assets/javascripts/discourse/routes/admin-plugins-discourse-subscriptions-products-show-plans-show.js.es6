import AdminPlan from "discourse/plugins/discourse-subscriptions/discourse/models/admin-plan";
import Group from "discourse/models/group";

export default Discourse.Route.extend({
  model(params) {
    const id = params["plan-id"];
    const product = this.modelFor(
      "adminPlugins.discourse-subscriptions.products.show"
    ).product;
    let plan;

    if (id === "new") {
      plan = AdminPlan.create({
        active: true,
        isNew: true,
        currency: Discourse.SiteSettings.discourse_subscriptions_currency,
        product: product.get("id")
      });
    } else {
      plan = AdminPlan.find(id);
    }

    const groups = Group.findAll({ ignore_automatic: true });

    return Ember.RSVP.hash({ plan, product, groups });
  },

  renderTemplate() {
    this.render(
      "adminPlugins.discourse-subscriptions.products.show.plans.show",
      {
        into: "adminPlugins.discourse-subscriptions.products",
        outlet: "main",
        controller:
          "adminPlugins.discourse-subscriptions.products.show.plans.show"
      }
    );
  }
});
