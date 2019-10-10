import AdminPlan from "discourse/plugins/discourse-patrons/discourse/models/admin-plan";

export default Discourse.Route.extend({
  model() {
    return AdminPlan.find();
  },

  actions: {
    destroyPlan(plan) {
      bootbox.confirm(
        I18n.t("discourse_patrons.admin.plans.operations.destroy.confirm"),
        I18n.t("no_value"),
        I18n.t("yes_value"),
        confirmed => {
          if (confirmed) {
            this.controllerFor("adminPluginsDiscoursePatronsPlansIndex")
              .get("model")
              .removeObject(plan);
          }
        }
      );
    }
  }
});
