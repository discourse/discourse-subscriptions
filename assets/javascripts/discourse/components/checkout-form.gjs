import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import SubscribeCard from "./subscribe-card";
import { i18n } from "discourse-i18n";
import { eq } from "truth-helpers";
import DButton from "discourse/components/d-button";
import { on } from '@ember/modifier';
import { Input } from "@ember/component";
import formatCurrency from "../helpers/format-currency";

export default class CheckoutForm extends Component {
  @service siteSettings;
  @tracked promoCode = null;
  @tracked cardholderName = null;

  @action
  submitForm(event) {
    event.preventDefault();
    this.args.onSubmit({
      promoCode: this.promoCode,
      cardholderName: this.cardholderName,
    });
  }

  <template>
    <div class="checkout-form-container">
      <button {{on "click" @onClose}} class="close-checkout-btn" title="cancel">
        &times;
      </button>

      <h2>{{@product.name}}</h2>
      <p class="plan-selection-summary">
        You've selected the <strong>{{@plan.nickname}}</strong> plan.
      </p>

      <div class="price-summary">
        Total due today:
        <span>{{formatCurrency @plan.currency @plan.amountDollars}}</span>
      </div>

      <form {{on "submit" this.submitForm}}>
        {{#if (eq this.siteSettings.discourse_subscriptions_payment_provider "Stripe")}}
          <div class="stripe-form">
            <label for="cardholderName">Cardholder Name</label>
            <Input @type="text" id="cardholderName" @value={{this.cardholderName}} required />

            <label for="card-element">Card Details</label>
            <SubscribeCard @cardElement={{@cardElement}} />
          </div>
        {{/if}}

        <DButton
          @type="submit"
          class="btn-primary btn-final-pay"
          @disabled={{@isLoading}}
          @label="discourse_subscriptions.buttons.confirm_payment"
        />
      </form>
    </div>
  </template>
}
