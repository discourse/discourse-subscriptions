import { ajax } from "discourse/lib/ajax";

export default {
  finalize(plan, transaction) {
    const data = {
      plan: plan,
      transaction: transaction
    };
    return ajax("/s/subscriptions/finalize", { method: "post", data });
  }
};
