import Component from "@ember/component";
import { LinkTo } from "@ember/routing";
import { classNames, tagName } from "@ember-decorators/component";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";
import userViewingSelf from "../../helpers/user-viewing-self";

@tagName("li")
@classNames("user-main-nav-outlet", "billing")
export default class Billing extends Component {
  <template>
    {{#if (userViewingSelf this.model)}}
      <LinkTo @route="user.billing">
        {{icon "far-credit-card"}}
        {{i18n "discourse_subscriptions.navigation.billing"}}
      </LinkTo>
    {{/if}}
  </template>
}
