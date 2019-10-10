export default function() {
  this.route("patrons", function() {
    this.route("subscribe");
    this.route("show", { path: ":pid" });
  });
}
