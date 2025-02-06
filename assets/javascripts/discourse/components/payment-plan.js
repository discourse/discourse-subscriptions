import Component from "@ember/component";
import { action } from "@ember/object";
import { tagName } from "@ember-decorators/component";
import discourseComputed from "discourse/lib/decorators";

const RECURRING = "recurring";

@tagName("")
export default class PaymentPlan extends Component {
  @discourseComputed("selectedPlan")
  selectedClass(planId) {
    return planId === this.plan.id ? "btn-primary" : "";
  }

  @discourseComputed("plan.type")
  recurringPlan(type) {
    return type === RECURRING;
  }

  @action
  planClick() {
    this.clickPlan(this.plan);
    return false;
  }
}
