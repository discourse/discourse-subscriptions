import { ajax } from "discourse/lib/ajax";

export default {
  finalize(transaction, plan) {
    const data = {
      transaction: transaction,
      plan: plan
    };

    return ajax("/s/subscriptions/finalize", { method: "post", data });
  }
};
