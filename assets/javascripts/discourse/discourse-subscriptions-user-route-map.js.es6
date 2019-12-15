export default {
  resource: "user",
  path: "users/:username",
  map() {
    this.route("billing", function() {
      this.route("payments");
      this.route("subscriptions");
    });
  }
};
