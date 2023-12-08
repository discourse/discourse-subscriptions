import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import { hash } from "@ember/helper";
import i18n from "discourse-common/helpers/i18n";
import { Input } from "@ember/component";

const AdminCancelSubscriptions = <template>
  <DModal
    @title={{i18n
      "discourse_subscriptions.user.subscriptions.operations.destroy.confirm"
    }}
    @closeModal={{@closeModal}}
  >
    <:body>
      <Input @type="checkbox" @checked={{refund}} />
      {{i18n "discourse_subscriptions.admin.ask_refund"}}
    </:body>
    <:footer>
      <ConditionalLoadingSpinner @condition={{@model.subscription.loading}}>
        <DButton
          @label="yes_value"
          @action={{route-action
            "cancelSubscription"
            (hash
              subscription=@model.subscription refund=@model.subscription.refund
            )
          }}
          @icon="times"
          class="btn-danger"
        />
        <DButton @label="no_value" @action={{@closeModal}} />
      </ConditionalLoadingSpinner>
    </:footer>
  </DModal>
</template>;

export default AdminCancelSubscriptions;
