
export default Ember.Helper.helper(function(params) {
  let currencySign;

  switch (Discourse.SiteSettings.discourse_patrons_currency) {
    case "EUR":
      currencySign = "€";
      break;
    case "GBP":
      currencySign = "£";
      break;
    default:
      currencySign = "$";
  }

  return currencySign + params.map(p => p.toUpperCase()).join(' ');
});
