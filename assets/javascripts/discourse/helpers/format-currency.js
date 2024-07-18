import { helper } from "@ember/component/helper";

export function formatCurrency([currency, amount]) {
  let currencySign;

  switch (currency.toUpperCase()) {
    case "EUR":
      currencySign = "€";
      break;
    case "GBP":
      currencySign = "£";
      break;
    case "INR":
      currencySign = "₹";
      break;
    case "BRL":
      currencySign = "R$";
      break;
    case "DKK":
      currencySign = "DKK";
      break;
    case "SGD":
      currencySign = "S$";
      break;
    case "ZAR":
      currencySign = "R";
      break;
    default:
      currencySign = "$";
  }

  let formattedAmount = parseFloat(amount).toFixed(2);
  return currencySign + formattedAmount;
}

export default helper(formatCurrency);
