export default function () {
  this.route("subscribe", { path: "/s" }, function () {
    this.route("show", { path: "/:subscription-id" });
  });
  this.route("subscriptions");
}
