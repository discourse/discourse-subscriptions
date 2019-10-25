import Group from "discourse/plugins/discourse-patrons/discourse/models/group";
import Plan from "discourse/plugins/discourse-patrons/discourse/models/plan";
import Subscription from "discourse/plugins/discourse-patrons/discourse/models/subscription";

export default Discourse.Route.extend({
  model() {
    const toCurrency = cents => parseFloat(cents / 100).toFixed(2);

    const planSelectText = plan => {
      return `$${toCurrency(plan.amount)} ${plan.currency.toUpperCase()} / ${
        plan.interval
      }`;
    };

    const plans = Plan.findAll().then(results =>
      results.map(p => planSelectText(p))
    );
    const subscription = Subscription.create();

    return Ember.RSVP.hash({ plans, subscription });
  }
});
