import Route from "@ember/routing/route";
import Product from "discourse/plugins/discourse-subscriptions/discourse/models/product";
import Plan from "discourse/plugins/discourse-subscriptions/discourse/models/plan"; // Import the Plan model

export default class SubscribeIndexRoute extends Route {
  model() {
    return Product.findAll().then(products => {
      // Loop through each product returned from the server
      products.forEach(product => {
        // Check if the product has a 'plans' array
        if (product.plans && product.plans.length > 0) {
          // Overwrite the plain JavaScript 'plans' array with an array
          // of proper Ember Plan models that have the 'amountDollars' getter.
          const planModels = product.plans.map(p => Plan.create(p));
          product.set('plans', planModels);
        }
      });
      return products;
    });
  }

  // NOTE: The afterModel hook that caused redirects has been removed
  // to ensure this new pricing page is always shown.
}
