import Component from "@ember/component";
import { action } from "@ember/object";
import discourseComputed from "discourse/lib/decorators";

export default class PaymentOptions extends Component {
  @discourseComputed("plans")
  orderedPlans(plans) {
    if (plans) {
      return plans.sort((a, b) => (a.unit_amount > b.unit_amount ? 1 : -1));
    }
  }

  didInsertElement() {
    super.didInsertElement(...arguments);
    if (this.plans && this.plans.length === 1) {
      this.set("selectedPlan", this.plans[0].id);
    }
  }

  @action
  clickPlan(plan) {
    this.set("selectedPlan", plan.id);
  }
}
