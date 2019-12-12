export default function() {
  this.route("s", function() {
    this.route("subscribe", function() {
      this.route("show", { path: "/:subscription-id" });
    });
  });
}
