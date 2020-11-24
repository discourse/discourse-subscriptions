import Route from "@ember/routing/route";
import AdminPlan from "discourse/plugins/discourse-subscriptions/discourse/models/admin-plan";
import Group from "discourse/models/group";
import { hash } from "rsvp";

export default Route.extend({
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
        interval: "month",
        type: "recurring",
        isRecurring: true,
        currency: Discourse.SiteSettings.discourse_subscriptions_currency,
        product: product.get("id"),
        metadata: {
          group_name: null,
        },
      });
    } else {
      plan = AdminPlan.find(id).then((result) => {
        result.isRecurring = result.type === "recurring";

        return result;
      });
    }

    const groups = Group.findAll({ ignore_automatic: true });

    return hash({ plan, product, groups });
  },

  renderTemplate() {
    this.render(
      "adminPlugins.discourse-subscriptions.products.show.plans.show",
      {
        into: "adminPlugins.discourse-subscriptions.products",
        outlet: "main",
        controller:
          "adminPlugins.discourse-subscriptions.products.show.plans.show",
      }
    );
  },
});
