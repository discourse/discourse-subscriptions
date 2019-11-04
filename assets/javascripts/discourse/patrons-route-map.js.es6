export default function() {
  this.route("patrons", function() {
    this.route("subscribe", function() {
      this.route("show", { path: "/:subscription-id" });
    });
  });
}
