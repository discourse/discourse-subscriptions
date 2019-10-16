import AdminPlan from "discourse/plugins/discourse-patrons/discourse/models/admin-plan";

export default Discourse.Route.extend({
  model() {
    return AdminPlan.findAll();
  },

  actions: {
    destroyPlan(plan) {
      bootbox.confirm(
        I18n.t("discourse_patrons.admin.plans.operations.destroy.confirm"),
        I18n.t("no_value"),
        I18n.t("yes_value"),
        confirmed => {
          if (confirmed) {
            plan.destroy().then(() => {
              this.controllerFor("adminPluginsDiscoursePatronsPlansIndex")
              .get("model")
              .removeObject(plan);
            })
            .catch(data => bootbox.alert(data.jqXHR.responseJSON.errors.join("\n")));
          }
        }
      );
    }
  }
});
