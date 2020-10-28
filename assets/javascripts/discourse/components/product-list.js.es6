import discourseComputed from "discourse-common/utils/decorators";
import { isEmpty } from "@ember/utils";
import Component from "@ember/component";

export default Component.extend({
  classNames: ["product-list"],

  @discourseComputed("products")
  emptyProducts(products) {
    return isEmpty(products);
  },
});
