export default function() {
  this.route("patrons", function() {
    this.route("subscribe", function() {
      this.route("product", { path: ":product_id" })
    });
    this.route("show", { path: ":pid" });
  });
}
