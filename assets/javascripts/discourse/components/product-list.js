import Component from "@ember/component";
import { isEmpty } from "@ember/utils";
import { classNames } from "@ember-decorators/component";
import discourseComputed from "discourse/lib/decorators";

@classNames("product-list")
export default class ProductList extends Component {
  @discourseComputed("products")
  emptyProducts(products) {
    return isEmpty(products);
  }
}
