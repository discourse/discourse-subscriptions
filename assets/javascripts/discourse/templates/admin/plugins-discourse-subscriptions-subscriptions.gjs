import { fn } from "@ember/helper";
import { eq } from "truth-helpers";
import { LinkTo } from "@ember/routing";
import RouteTemplate from "ember-route-template";
import DButton from "discourse/components/d-button";
import loadingSpinner from "discourse/helpers/loading-spinner";
import { i18n } from "discourse-i18n";
import formatUnixDate from "../../helpers/format-unix-date";
import formatAbsoluteDate from "../../helpers/format-absolute-date";
import UserAvatar from "discourse/components/user-avatar";
import LoadMore from "discourse/components/load-more";
import UserChooser from "select-kit/components/user-chooser";

export default RouteTemplate(
<template>
  {{#if @controller.unconfigured}}
    <p>{{i18n "discourse_subscriptions.admin.unconfigured"}}</p>
  {{else}}
    <div class="subscription-controls">
      <UserChooser
        @value={{@controller.username}}
        @onChange={{@controller.filterByUser}}
        @maximum={{1}}
        @placeholder="Filter by user..."
      />
      {{#if @controller.username}}
        <DButton
          @action={{@controller.clearFilter}}
          @icon="times"
          class="btn-icon btn-clear-filter"
          @title="Clear filter"
        />
      {{/if}}
    </div>

    <LoadMore @action={{@controller.loadMore}} @selector=".subscription-item" @isLoading={{@controller.isLoadingMore}} @more={{@controller.meta.more}}>
      {{#if @controller.subscriptions.length}}
        <table class="table">
          <thead>
          <th>User</th>
          <th>Provider</th>
          <th>Product</th>
          <th>Plan</th>
          <th>Amount</th>
          <th>Status</th>
          <th>Created</th>
          <th>Expires/Renews</th>
          <th></th>
          </thead>
          <tbody>
          {{#each @controller.subscriptions as |subscription|}}
            <tr class="subscription-item {{if (eq subscription.status "revoked") "revoked-subscription"}}">
              <td>
                <LinkTo @route="user" @model={{subscription.user}}>
                  <UserAvatar @username={{subscription.user.username}} @size="small" />
                  {{subscription.user.username}}
                </LinkTo>
              </td>
              <td>{{subscription.provider}}</td>
              <td>{{subscription.plan_name}}</td>
              <td>{{subscription.plan_nickname}}</td>
              <td>{{subscription.amountDollars}}</td>
              <td><span class="status-badge">{{subscription.status}}</span></td>
              <td>{{formatUnixDate subscription.created_at}}</td>
              <td>{{formatAbsoluteDate subscription.expires_at}}</td>
              <td class="td-right">
                {{#if subscription.loading}}
                  {{loadingSpinner size="small"}}
                {{else if (eq subscription.provider "Stripe")}}
                  <DButton
                    @disabled={{eq subscription.status "canceled"}}
                    @label="cancel"
                    @action={{fn @controller.showCancelModal subscription}}
                    @icon="xmark"
                  />
                {{else}}
                  <DButton
                    @disabled={{eq subscription.status "revoked"}}
                    @label="discourse_subscriptions.admin.revoke_access"
                    @action={{fn @controller.revokeAccess subscription}}
                    @icon="user-slash"
                    class="btn-danger"
                  />
                {{/if}}
              </td>
            </tr>
          {{/each}}
          </tbody>
        </table>
      {{else}}
        <p>No subscriptions found{{if @controller.username " for that user"}}.</p>
      {{/if}}
    </LoadMore>
  {{/if}}
</template>
);
