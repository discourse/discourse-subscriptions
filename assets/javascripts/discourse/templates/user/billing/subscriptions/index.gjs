import RouteTemplate from "ember-route-template";
import DButton from "discourse/components/d-button";
import loadingSpinner from "discourse/helpers/loading-spinner";
import routeAction from "discourse/helpers/route-action";
import { i18n } from "discourse-i18n";
import formatUnixDate from "../../../../helpers/format-unix-date";
import formatCurrency from "../../../../helpers/format-currency";
import { and, not } from "truth-helpers";

export default RouteTemplate(
  <template>
    {{#if @controller.stripeSubscriptions.length}}
      <h4>Recurring Subscriptions (Stripe)</h4>
      <table class="table discourse-subscriptions-user-table">
        <thead>
          <th>{{i18n "discourse_subscriptions.user.subscriptions.id"}}</th>
          <th>{{i18n "discourse_subscriptions.user.plans.product"}}</th>
          <th>{{i18n "discourse_subscriptions.user.plans.rate"}}</th>
          <th>{{i18n "discourse_subscriptions.user.subscriptions.status"}}</th>
          <th>{{i18n "discourse_subscriptions.user.subscriptions.renews"}}</th>
          <th>{{i18n "discourse_subscriptions.user.subscriptions.created_at"}}</th>
          <th></th>
        </thead>
        <tbody>
          {{#each @controller.stripeSubscriptions as |subscription|}}
            <tr>
              <td>{{subscription.id}}</td>
              <td>{{subscription.product.name}}</td>
              <td>{{subscription.plan.subscriptionRate}}</td>
              <td>{{subscription.status}}</td>
              <td>{{subscription.endDate}}</td>
              <td>{{formatUnixDate subscription.created}}</td>
              <td class="td-right">
                {{#if subscription.loading}}
                  {{loadingSpinner size="small"}}
                {{else}}
                  {{#if subscription.canceled_at}}
                    <DButton @disabled={{true}} @label="discourse_subscriptions.user.subscriptions.cancelled" />
                  {{else}}
                    <DButton @action={{routeAction "updateCard" subscription.id}} @icon="far-pen-to-square" class="btn no-text btn-icon" />
                    <DButton class="btn-danger btn no-text btn-icon" @icon="trash-can" @action={{routeAction "cancelSubscription" subscription}} />
                  {{/if}}
                {{/if}}
              </td>
            </tr>
          {{/each}}
        </tbody>
      </table>
    {{/if}}

    {{#if @controller.razorpayPurchases.length}}
      <h4>One-Time Purchases (Razorpay)</h4>
      <table class="table discourse-subscriptions-user-table">
        <thead>
          <th>Payment ID</th>
          <th>Name</th>
          <th>Amount</th>
          <th>Date</th>
        </thead>
        <tbody>
          {{#each @controller.razorpayPurchases as |purchase|}}
            <tr>
              <td>{{purchase.id}}</td>
              <td>{{purchase.plan_name}}</td>
              <td>{{formatCurrency purchase.currency purchase.amount_dollars}}</td>
              <td>{{formatUnixDate purchase.created_at}}</td>
            </tr>
          {{/each}}
        </tbody>
      </table>
    {{/if}}

    {{#if (and (not @controller.stripeSubscriptions.length) (not @controller.razorpayPurchases.length))}}
      <div class="alert alert-info">
        {{i18n "discourse_subscriptions.user.subscriptions_help"}}
      </div>
    {{/if}}
  </template>
);
