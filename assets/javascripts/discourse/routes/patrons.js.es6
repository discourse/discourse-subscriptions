import { ajax } from "discourse/lib/ajax";

export default Discourse.Route.extend({
  model() {
    const user = Ember.Object.create({
      name: "",
      email: "",
      phone: ""
    });

    return ajax("/patrons/patrons", {
      method: "get"
    }).then((result) => {
      user.set('email', result.email);
      return user;
    }).catch(() => {
      return user;
    });
  }
});
