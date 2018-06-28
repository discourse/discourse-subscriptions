const formatAnchor = function(type = null, time = moment()) {
  let format;

  switch(type) {
    case 'once':
      format = 'Do MMMM YYYY';
      break;
    case 'week':
      format = 'dddd';
      break;
    case 'month':
      format = 'Do';
      break;
    case 'year':
      format = 'MMMM D';
      break;
    default:
      format = 'dddd';
  }

  return moment(time).format(format);
}

const zeroDecimalCurrencies = ['MGA', 'BIF', 'CLP', 'PYG', 'DFJ', 'RWF', 'GNF', 'UGX', 'JPY', 'VND', 'VUV', 'XAF', 'KMF', 'KRW', 'XOF', 'XPF'];

const formatAmount = function(amount, currency) {
  let zeroDecimal = zeroDecimalCurrencies.indexOf(currency) > -1;
  return zeroDecimal ? amount : (amount / 100).toFixed(2);
}

export { formatAnchor, formatAmount, zeroDecimalCurrencies }
