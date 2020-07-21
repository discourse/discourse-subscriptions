import { equal } from "@ember/object/computed";
import Component from "@ember/component";

export default Component.extend({

  actions: {
    clickPlan(plan) {
      this.set("selectedPlan", plan.id);
    }
  }
});
