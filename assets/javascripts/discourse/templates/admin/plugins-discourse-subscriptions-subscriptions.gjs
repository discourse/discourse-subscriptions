import { fn } from "@ember/helper";
import { and, not, eq } from "truth-helpers";
import { LinkTo } from "@ember/routing";
import RouteTemplate from "ember-route-template";
import DButton from "discourse/components/d-button";
import loadingSpinner from "discourse/helpers/loading-spinner";
import { i18n } from "discourse-i18n";
import formatUnixDate from "../../helpers/format-unix-date";
import formatCurrency from "../../helpers/format-currency";
import UserAvatar from "discourse/components/user-avatar";

export default RouteTemplate(
  <template>
    {{#if @controller.model.unconfigured}}
      <p>{{i18n "discourse_subscriptions.admin.unconfigured"}}</p>
    {{else}}
      {{#if @controller.stripeSubscriptions.length}}
        <h4>Recurring Subscriptions (Stripe)</h4>
        <table class="table">
          {{!-- ... Stripe table is unchanged ... --}}
        </table>
      {{/if}}

      {{#if @controller.razorpayPurchases.length}}
        <h4 style="margin-top: 2em;">One-Time Purchases (Razorpay)</h4>
        <table class="table">
          <thead>
            <th>User</th>
            <th>Payment ID</th>
            <th>Product</th>
            <th>Amount</th>
            <th class="td-right">Date</th>
            <th></th> {{! New Actions column }}
          </thead>
          <tbody>
            {{#each @controller.razorpayPurchases as |purchase|}}
              <tr>
                <td>
                  <LinkTo @route="user" @model={{purchase.user}}>
                    <UserAvatar @username={{purchase.user.username}} @size="small" />
                    {{purchase.user.username}}
                  </LinkTo>
                </td>
                <td>{{purchase.id}}</td>
                <td>{{purchase.plan.product.name}}</td>
                <td>{{formatCurrency purchase.currency purchase.amount_dollars}}</td>
                <td class="td-right">{{formatUnixDate purchase.created_at}}</td>
                {{! --- START OF NEW BUTTON LOGIC --- }}
                <td class="td-right">
                  {{#if purchase.loading}}
                    {{loadingSpinner size="small"}}
                  {{else}}
                    <DButton
                      @disabled={{eq purchase.status "revoked"}}
                      @label="discourse_subscriptions.admin.revoke_access" {{! We'll need to add this text }}
                      @action={{fn @controller.revokeRazorpayPurchase purchase}}
                      @icon="user-slash"
                      class="btn-danger"
                    />
                  {{/if}}
                </td>
                {{! --- END OF NEW BUTTON LOGIC --- }}
              </tr>
            {{/each}}
          </tbody>
        </table>
      {{/if}}

      {{#if (and (not @controller.stripeSubscriptions.length) (not @controller.razorpayPurchases.length))}}
        <p>No subscriptions found.</p>
      {{/if}}
    {{/if}}
  </template>
);
