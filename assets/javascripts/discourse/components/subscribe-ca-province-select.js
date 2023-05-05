import ComboBoxComponent from "select-kit/components/combo-box";
import { computed } from "@ember/object";
import I18n from "I18n";

export default ComboBoxComponent.extend({
  pluginApiIdentifiers: ["subscribe-ca-province-select"],
  classNames: ["subscribe-address-state-select"],
  nameProperty: "name",
  valueProperty: "value",

  selectKitOptions: {
    filterable: true,
    allowAny: false,
    translatedNone: I18n.t(
      "discourse_subscriptions.subscribe.cardholder_address.province"
    ),
  },

  content: computed(function () {
    return [
      ["AB", "Alberta"],
      ["BC", "British Columbia"],
      ["MB", "Manitoba"],
      ["NB", "New Brunswick"],
      ["NL", "Newfoundland and Labrador"],
      ["NT", "Northwest Territories"],
      ["NS", "Nova Scotia"],
      ["NU", "Nunavut"],
      ["ON", "Ontario"],
      ["PE", "Prince Edward Island"],
      ["QC", "Quebec"],
      ["SK", "Saskatchewan"],
      ["YT", "Yukon"],
    ].map((arr) => {
      return { value: arr[0], name: arr[1] };
    });
  }),
});
