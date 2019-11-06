import { registerUnbound } from "discourse-common/lib/helpers";

export default registerUnbound("show-extra-nav", function(model) {
  return Discourse.SiteSettings.discourse_patrons_extra_nav_subscribe;
});
