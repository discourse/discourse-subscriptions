import Product from "discourse/plugins/discourse-patrons/discourse/models/product";
import Plan from "discourse/plugins/discourse-patrons/discourse/models/plan";
import Subscription from "discourse/plugins/discourse-patrons/discourse/models/subscription";

export default Discourse.Route.extend({
  model(params) {
  const product_id = params["subscription-id"];
  const product = Product.find(product_id);
  const subscription = Subscription.create();
  const plans = Plan.findAll({ product_id: product_id }).then(results =>
    results.map(p => ({ id: p.id, name: p.subscriptionRate }))
  );

  return Ember.RSVP.hash({ plans, product, subscription });
  },
});
