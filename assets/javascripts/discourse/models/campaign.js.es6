import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";

const Campaign = EmberObject.extend({});

Campaign.reopenClass({
  getInfo() {
    return ajax("/s/campaign", { method: "get" }).then((result) => 
      Campaign.create(result)
    );
  },
});

export default Campaign;
