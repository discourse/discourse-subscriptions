import { ajax } from "discourse/lib/ajax";
import { default as getURL } from "discourse-common/lib/get-url";

export default {
  finalize(transaction, plan) {
    const data = {
      transaction: transaction,
      plan: plan,
    };

    return ajax(getURL("/s/finalize"), { method: "post", data });
  },
};
