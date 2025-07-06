import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import { i18n } from "discourse-i18n";
import ComboBox from "select-kit/components/combo-box";
import UserChooser from "select-kit/components/user-chooser";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import AdminProduct from "discourse/plugins/discourse-subscriptions/discourse/models/admin-product";
import { eq } from "truth-helpers";
import { Input } from "@ember/component";

export default class GrantSubscriptionModal extends Component {
  @service dialog;
  @service router;

  @tracked allPlans = [];
  @tracked selectedPlanId = null;
  @tracked selectedUsername = null;
  @tracked duration = null;
  @tracked isLoading = true;

  constructor() {
    super(...arguments);
    this.loadData();
  }

  get selectedPlan() {
    return this.allPlans.find((p) => p.id === this.selectedPlanId);
  }

  get isOneTimePlan() {
    return this.selectedPlan && this.selectedPlan.type !== "recurring";
  }

  // FIX #1: This action now handles both single string and array inputs
  // from the UserChooser for maximum compatibility.
  @action
  updateUsername(selection) {
    if (Array.isArray(selection) && selection.length > 0) {
      this.selectedUsername = selection[0]; // Take the first item if it's an array
    } else {
      this.selectedUsername = selection;
    }
  }

  @action
  async loadData() {
    this.isLoading = true;
    try {
      const products = await AdminProduct.findAll();
      const productsWithPlans = await Promise.all(
        products.map(async (p) => {
          if (p.id) {
            const plans = await ajax(`/s/admin/plans.json?product_id=${p.id}`);
            p.set("plans", plans);
          }
          return p;
        })
      );

      const flattenedPlans = [];
      productsWithPlans.forEach((product) => {
        if (product.plans && product.plans.length > 0) {
          product.plans.forEach((plan) => {
            flattenedPlans.push({
              id: plan.id,
              name: `${product.name} - ${plan.nickname} (${(
                plan.unit_amount / 100.0
              ).toFixed(2)} ${plan.currency.toUpperCase()})`,
              type: plan.type,
            });
          });
        }
      });
      this.allPlans = flattenedPlans;
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isLoading = false;
    }
  }

  @action
  grantSubscription() {
    if (!this.selectedUsername || !this.selectedPlanId) {
      this.dialog.alert("Please select a user and a plan.");
      return;
    }

    const grantData = {
      username: this.selectedUsername,
      plan_id: this.selectedPlanId,
      duration: this.duration,
    };

    // You can remove the console.log now if you wish
    // console.log("Data being sent to server:", grantData);

    this.isLoading = true;

    ajax("/s/admin/subscriptions/grant", {
      method: "POST",
      data: grantData,
    })
      .then(() => {
        this.dialog.alert("Subscription granted successfully.");
        this.args.closeModal();
        this.router.refresh();
      })
      .catch(popupAjaxError)
      .finally(() => {
        this.isLoading = false;
      });
  }

  <template>
    <DModal @title={{i18n "discourse_subscriptions.admin.grant_subscription_modal.title"}} @closeModal={{@closeModal}}>
      <:body>
        {{#if this.isLoading}}
          <div class="spinner"></div>
        {{else}}
          <div class="form-horizontal">
            <div class="control-group">
              <label class="control-label">User</label>
              <div class="controls">
                {{! FIX #2: Add maximum="1" to ensure it only allows a single selection }}
                <UserChooser @value={{this.selectedUsername}} @onChange={{this.updateUsername}} @maximum={{1}} />
              </div>
            </div>

            <div class="control-group">
              <label class="control-label">Plan</label>
              <div class="controls">
                <ComboBox
                  @value={{this.selectedPlanId}}
                  @content={{this.allPlans}}
                  @valueProperty="id"
                  @nameProperty="name"
                />
              </div>
            </div>

            {{#if this.isOneTimePlan}}
              <div class="control-group">
                <label class="control-label">Duration (in days)</label>
                <div class="controls">
                  <Input @type="number" @value={{this.duration}} placeholder="e.g., 30 (leave blank for permanent)" min="1" />
                </div>
              </div>
            {{/if}}
          </div>
        {{/if}}
      </:body>
      <:footer>
        <DButton @action={{@closeModal}} @label="cancel" />
        <DButton @action={{this.grantSubscription}} @label={{i18n "discourse_subscriptions.admin.grant_subscription_modal.grant"}} class="btn-primary" @disabled={{this.isLoading}} />
      </:footer>
    </DModal>
  </template>
}
