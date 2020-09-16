export default function () {
  this.route("s", function () {
    this.route("show", { path: "/:subscription-id" });
  });
}
