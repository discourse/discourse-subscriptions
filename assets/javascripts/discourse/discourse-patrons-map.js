
export default function() {
  const { disabled_plugins = [] } = this.site;

  if (disabled_plugins.indexOf("discourse-patrons") !== -1) {
    return;
  }

  this.route("patrons", function() {
    this.route("show", { path: ":payment_id" });
  });
}
