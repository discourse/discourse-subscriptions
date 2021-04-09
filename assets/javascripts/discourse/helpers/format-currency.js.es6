import Helper from "@ember/component/helper";

export default Helper.helper(function (params) {
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
    case "INR":
    case "inr":
      currencySign = "₹";
      break;
    case "BRL":
    case "brl":
      currencySign = "R$";
      break;
    case "DKK":
    case "dkk":
      currencySign = "DKK";
      break;
    default:
      currencySign = "$";
  }

  return currencySign + params[1];
});
