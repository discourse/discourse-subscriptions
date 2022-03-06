import Helper from "@ember/component/helper";

export default Helper.helper(function (params) {
  const payment = params[0];

  return `<a href=\"${payment.url}\">${payment.payment_intent_id}</a>`;
});
