import Controller from "@ember/controller";
import User from "discourse/models/user";
import discourseComputed from "discourse-common/utils/decorators";

export default class SubscribeIndexController extends Controller {
  @discourseComputed()
  isLoggedIn() {
    return User.current();
  }
}
