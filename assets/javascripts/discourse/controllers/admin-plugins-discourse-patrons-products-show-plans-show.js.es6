import computed from "ember-addons/ember-computed-decorators";
import DiscourseURL from "discourse/lib/url";

export default Ember.Controller.extend({
  // Also defined in settings.
  currencies: ['AUD', 'CAD', 'EUR', 'GBP', 'USD'],

  @computed("model.plan.isNew")
  planFieldDisabled(isNew) {
    return !isNew;
  },

  @computed("model.product.id")
  productId(id) {
    return id;
  },

  redirect(product_id) {
    DiscourseURL.redirectTo(
      `/admin/plugins/discourse-patrons/products/${product_id}`
    );
  },

  actions: {
    cancelPlan(product_id) {
      this.redirect(product_id);
    },

    createPlan() {
      // TODO: set default group name beforehand
      if (this.get("model.plan.metadata.group_name") === undefined) {
        this.set("model.plan.metadata", {
          group_name: this.get("model.groups.firstObject.name")
        });
      }

      this.get("model.plan")
        .save()
        .then(() => this.redirect(this.productId))
        .catch(data =>
          bootbox.alert(data.jqXHR.responseJSON.errors.join("\n"))
        );
    },

    updatePlan() {
      this.get("model.plan")
        .update()
        .then(() => this.redirect(this.productId))
        .catch(data =>
          bootbox.alert(data.jqXHR.responseJSON.errors.join("\n"))
        );
    }
  }
});
