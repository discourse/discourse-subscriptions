export default {
  resource: "user",
  path: "users/:username",
  map() {
    this.route("billing");
  }
};
