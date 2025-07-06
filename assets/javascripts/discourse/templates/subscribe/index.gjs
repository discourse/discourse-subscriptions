import RouteTemplate from "ember-route-template";
import LoginRequired from "../../components/login-required";
import PricingCard from "../../components/pricing-card";
import CheckoutForm from "../../components/checkout-form";
import { i18n } from "discourse-i18n";

export default RouteTemplate(
<template>
  {{#if @controller.currentUser}}
    <div class="pricing-page-wrapper">
      {{#if @controller.productForCheckout}}
        <CheckoutForm
          @product={{@controller.productForCheckout}}
          @plan={{@controller.planForCheckout}}
          @cardElement={{@controller.cardElement}}
          @isLoading={{@controller.loading}}
          @onSubmit={{@controller.initiatePayment}}
          @onClose={{@controller.cancelCheckout}}
        />
      {{else}}
        <div class="pricing-container">
          {{#if @controller.model.length}}
            {{#each @controller.model as |product|}}
              <PricingCard @product={{product}} @startCheckout={{@controller.startCheckout}} />
            {{/each}}
          {{else}}
            <div class="alert alert-info">
              {{i18n "discourse_subscriptions.subscribe.no_products"}}
            </div>
          {{/if}}
        </div>
      {{/if}}
    </div>
  {{else}}
    <LoginRequired />
  {{/if}}
</template>
);
