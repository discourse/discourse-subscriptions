import Plan from "discourse/plugins/discourse-patrons/discourse/models/plan";
import Subscription from "discourse/plugins/discourse-patrons/discourse/models/subscription";

export default Discourse.Route.extend({
  model() {
    const plans = Plan.findAll().then(results =>
      results.map(p => ({ id: p.id, name: p.subscriptionRate }))
    );

    const subscription = Subscription.create();

    return Ember.RSVP.hash({ plans, subscription });
  }
});
