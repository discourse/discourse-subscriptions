import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { i18n } from "discourse-i18n";
import htmlSafe from "discourse/helpers/html-safe";
import formatCurrency from "../helpers/format-currency";
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { eq } from 'truth-helpers';
import DButton from "discourse/components/d-button";

const intervalToMonths = (interval, count) => {
  const c = count || 1;
  switch (interval) {
    case 'day': return c / 30.0;
    case 'week': return c / 4.0;
    case 'month': return c;
    case 'year': return c * 12;
    default: return 0;
  }
};

export default class PricingCard extends Component {
  @tracked selectedPlan;

  constructor() {
    super(...arguments);
    if (this.args.product.plans && this.args.product.plans.length > 0) {
      this.selectedPlan = this.args.product.plans.find(p => p.get('recurring.interval') === 'month') || this.args.product.plans[0];
    } else {
      this.selectedPlan = null;
    }
  }

  get processedPlans() {
    if (!this.args.product.plans || this.args.product.plans.length === 0) {
      return [];
    }
    const monthlyPlan = this.args.product.plans.find(p => p.get('recurring.interval') === 'month');

    return this.args.product.plans.map(plan => {
      let savings = null;
      let valueText = null;
      let totalMonths = 0;
      const isRecurring = !!plan.get('recurring');
      const isOneTimeExpiring = plan.get('type') === 'one_time' && plan.get('metadata.duration');

      if (isRecurring) {
        totalMonths = intervalToMonths(plan.get('recurring.interval'), plan.get('recurring.interval_count'));
      } else if (isOneTimeExpiring) {
        totalMonths = intervalToMonths('day', plan.get('metadata.duration'));
      }

      if (totalMonths > 0) {
        const monthlyEquivalent = plan.get('unit_amount') / totalMonths;
        valueText = `~${formatCurrency(plan.currency, monthlyEquivalent / 100)} / month`;
      }

      if (monthlyPlan && plan.id !== monthlyPlan.id && totalMonths > 0) {
        const totalCostAtBaseRate = monthlyPlan.get('unit_amount') * totalMonths;
        const savingAmount = totalCostAtBaseRate - plan.get('unit_amount');
        if (savingAmount > 0) {
          savings = `Save ${formatCurrency(plan.currency, savingAmount / 100)}`;
        }
      }
      return { planObject: plan, savings, valueText };
    });
  }

  @action
  selectPlan(processedPlan) {
    this.selectedPlan = processedPlan.planObject;
  }

  <template>
    <div class="pricing-card {{if @product.metadata.is_popular 'is-popular'}}">
      {{#if @product.metadata.is_popular}}
        <div class="popular-badge">Most popular</div>
      {{/if}}

      <div class="pricing-card-header">
        <h3>{{@product.name}}</h3>
        <p class="product-description">{{htmlSafe @product.description}}</p>
      </div>

      <div class="pricing-card-details">
        {{#if this.selectedPlan}}
          <div class="plan-selector">
            {{#each this.processedPlans as |p|}}
              <label class="plan-option">
                <input type="radio" name="plan-{{@product.id}}" checked={{eq p.planObject.id this.selectedPlan.id}} {{on "change" (fn this.selectPlan p)}}>
                <div class="plan-option-label">
                  <div class="plan-name-group">
                    <span class="plan-nickname">{{p.planObject.nickname}}</span>
                    {{#if p.savings}}
                      <span class="plan-savings-badge">{{p.savings}}</span>
                    {{/if}}
                  </div>
                  {{#if p.valueText}}
                    <span class="plan-value-text">{{p.valueText}}</span>
                  {{/if}}
                </div>
              </label>
            {{/each}}
          </div>

          <div class="price">
            <span class="price-amount">{{formatCurrency this.selectedPlan.currency this.selectedPlan.amountDollars}}</span>
            <span class="price-interval">
              {{#if this.selectedPlan.recurring}}
                billed every {{this.selectedPlan.recurring.interval}}
              {{else if this.selectedPlan.metadata.duration}}
                for {{this.selectedPlan.metadata.duration}} days access
              {{else}}
                one-time payment
              {{/if}}
            </span>
          </div>

          <DButton
            @action={{fn @startCheckout @product this.selectedPlan}}
            class="btn-primary btn-subscribe"
            @label="discourse_subscriptions.subscribe.title"
          />
        {{else}}
          <p class="no-plans-available">No plans are currently available for this product.</p>
        {{/if}}
      </div>
    </div>
  </template>
}
