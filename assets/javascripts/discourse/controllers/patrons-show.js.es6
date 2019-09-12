import DiscourseURL from "discourse/lib/url";

export default Ember.Controller.extend({
  actions: {
    goBack() {
      return DiscourseURL.redirectTo("/patrons");
    }
  }
});
