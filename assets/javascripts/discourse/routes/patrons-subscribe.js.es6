import Group from "discourse/plugins/discourse-patrons/discourse/models/group";
import Plan from "discourse/plugins/discourse-patrons/discourse/models/plan";
import Subscription from "discourse/plugins/discourse-patrons/discourse/models/subscription";

export default Discourse.Route.extend({
  model() {
    const group = Group.find();
    const plans = Plan.findAll().then(results => results.map(p => ({ id: p.id, name: p.nickname })));
    const subscription = Subscription.create();

    return Ember.RSVP.hash({ group, plans, subscription });
  }
});
