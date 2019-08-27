import { default as computed } from "ember-addons/ember-computed-decorators";

export default Ember.Component.extend({
  @computed
  causes() {
    const categoryEnabled =
      Discourse.SiteSettings.discourse_donations_cause_category;

    if (categoryEnabled) {
      let categoryIds = Discourse.SiteSettings.discourse_donations_causes_categories.split(
        "|"
      );

      if (categoryIds.length) {
        categoryIds = categoryIds.map(Number);
        return this.site
          .get("categoriesList")
          .filter(c => {
            return categoryIds.indexOf(c.id) > -1;
          })
          .map(c => {
            return {
              id: c.id,
              name: c.name
            };
          });
      } else {
        return [];
      }
    } else {
      const causes = Discourse.SiteSettings.discourse_donations_causes;
      return causes ? causes.split("|") : [];
    }
  }
});
