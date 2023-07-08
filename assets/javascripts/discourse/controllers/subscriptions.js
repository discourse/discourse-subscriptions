import Controller from "@ember/controller";
import Ember from 'ember';
import I18n from "I18n";

export default Controller.extend({
    init() {
        // Perform any initialization logic here
        this._super(...arguments);
        // Additional custom initialization code
        if(this.currentUser){
            this.currentUser.checkEmail().then((r)=>this.set('email',this.currentUser.email))
        }

      },
      pricingTable: Ember.computed('email', function() {
        try{
            const pricing_table_info = JSON.parse(this.siteSettings.discourse_subscriptions_pricing_table)
            if(this.currentUser){
                return`<stripe-pricing-table 
                pricing-table-id="${pricing_table_info.pricingTableId}"
                publishable-key="${pricing_table_info.publishableKey}"
                customer-email="${this.email}"></stripe-pricing-table>`;
            } else {
                return`<stripe-pricing-table 
                pricing-table-id="${pricing_table_info.pricingTableId}"
                publishable-key="${pricing_table_info.publishableKey}"
                ></stripe-pricing-table>`;
            }

        
        } catch(error){
            return I18n.t("discourse_subscriptions.subscribe.no_products")
        }
      }),
});
