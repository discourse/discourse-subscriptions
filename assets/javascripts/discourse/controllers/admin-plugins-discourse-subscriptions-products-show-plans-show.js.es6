import discourseComputed from "discourse-common/utils/decorators";
import DiscourseURL from "discourse/lib/url";
import Controller from "@ember/controller";

export default Controller.extend({
  // Also defined in settings.
  selectedCurrency: Ember.computed.alias("model.plan.currency"),
  selectedInterval: Ember.computed.alias("model.plan.interval"),

  @discourseComputed
  currencies() {
    return [
      { id: "AUD", name: "AUD" },
      { id: "CAD", name: "CAD" },
      { id: "EUR", name: "EUR" },
      { id: "GBP", name: "GBP" },
      { id: "USD", name: "USD" },
      { id: "INR", name: "INR" },
      { id: "BRL", name: "BRL" }
    ];
  },

  @discourseComputed
  availableIntervals() {
    return [
      { id: "day", name: "day" },
      { id: "week", name: "week" },
      { id: "month", name: "month" },
      { id: "year", name: "year" }
    ];
  },

  @discourseComputed("model.plan.isNew")
  planFieldDisabled(isNew) {
    return !isNew;
  },

  @discourseComputed("model.product.id")
  productId(id) {
    return id;
  },

  redirect(product_id) {
    DiscourseURL.redirectTo(
      `/admin/plugins/discourse-subscriptions/products/${product_id}`
    );
  },

  actions: {
    changeRecurring() {
      if (this.get("model.plan.isRecurring")) {
        this.set("model.plan.type", "one_time");
        this.set("model.plan.isRecurring", false);
      } else {
        this.set("model.plan.type", "recurring");
        this.set("model.plan.isRecurring", true);
      }
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
