import I18n from "I18n";
import Route from "@ember/routing/route";
import AdminSubscription from "discourse/plugins/discourse-subscriptions/discourse/models/admin-subscription";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";

export default Route.extend({
  dialog: service(),
  model() {
    return AdminSubscription.find();
  },
});
