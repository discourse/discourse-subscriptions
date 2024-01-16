import Component from "@ember/component";
import { isEmpty } from "@ember/utils";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  classNames: ["product-list"],

  @discourseComputed("products")
  emptyProducts(products) {
    return isEmpty(products);
  },
});
