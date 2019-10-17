import Group from "discourse/plugins/discourse-patrons/discourse/models/group";
import Plan from "discourse/plugins/discourse-patrons/discourse/models/plan";

export default Discourse.Route.extend({
  model() {
    const group = Group.find();
    const plans = Plan.findAll().then(results => results.map(p => p.id));

    return Ember.RSVP.hash({ group, plans });
  }
});
