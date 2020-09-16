import Route from "@ember/routing/route";
import Product from "discourse/plugins/discourse-subscriptions/discourse/models/product";
import Plan from "discourse/plugins/discourse-subscriptions/discourse/models/plan";
import { hash } from "rsvp";

export default Route.extend({
  model(params) {
    const product_id = params["subscription-id"];

    const product = Product.find(product_id);
    const plans = Plan.findAll({ product_id });

    return hash({ plans, product });
  },
});
