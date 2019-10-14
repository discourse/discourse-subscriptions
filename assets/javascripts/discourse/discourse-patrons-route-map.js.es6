export default {
  resource: "admin.adminPlugins",
  path: "/plugins",
  map() {
    this.route("discourse-patrons", function() {
      this.route("dashboard");
      this.route("products", function() {
        this.route("show", { path: "/:plan-id" });
      });
      this.route("plans", function() {
        this.route("show", { path: "/:plan-id" });
      });
      this.route("subscriptions");
    });
  }
};
