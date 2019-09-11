export default function() {
  this.route("patrons", function() {
    this.route("show", { path: ":pid" });
  });
}
