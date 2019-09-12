export default Discourse.Route.extend({
  model() {
    return Ember.Object.create({
      name: "",
      email: "",
      phone: ""
    });
  }
});
