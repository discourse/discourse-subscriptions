// TODO: typo in this helper name: currency not curency.
export default Ember.Helper.helper(function(params) {
  let currencySign;

  switch (Discourse.SiteSettings.discourse_subscriptions_currency) {
    case "EUR":
      currencySign = "€";
      break
    case "GBP":
      currencySign = "£";
      break
    case "INR":
      currencySign = "₹";
      break
    default:
      currencySign = "$";
  }

  return [currencySign, params[0]].join("");
});
