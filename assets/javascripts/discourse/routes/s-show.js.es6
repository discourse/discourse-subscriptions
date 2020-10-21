import Route from "@ember/routing/route";
import Product from "discourse/plugins/discourse-subscriptions/discourse/models/product";
import Plan from "discourse/plugins/discourse-subscriptions/discourse/models/plan";
import Subscription from "discourse/plugins/discourse-subscriptions/discourse/models/subscription";

export default Route.extend({
  model(params) {
    const product_id = params["subscription-id"];

    return Subscription.show(product_id).then((result) => {
      result.product = Product.create(result.product);
      result.plans = result.plans.map((plan) => {
        return Plan.create(plan);
      });

      return result;
    });
  },
});
