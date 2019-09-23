export default {
  resource: "admin.adminPlugins",
  path: "/plugins",
  map() {
    this.route("discourse-patrons", function() {
      this.route("subscriptions");
    });
  }
};
