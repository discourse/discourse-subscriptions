export default Ember.Helper.helper(function(params) {
  let currencySign;

  switch (params[0]) {
    case "EUR":
    case "eur":
      currencySign = "€";
      break;
    case "GBP":
    case "gbp":
      currencySign = "£";
      break;
    default:
      currencySign = "$";
  }

  return currencySign + params.map(p => p.toUpperCase()).join(" ");
});
