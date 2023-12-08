import DModal from "discourse/components/d-modal";
import i18n from "discourse-common/helpers/i18n";
import icon from "discourse-common/helpers/d-icon";
import { htmlSafe } from "@ember/template";

const AdminCancelSubscriptions = <template>
  <DModal
    @titl={{i18n
      "discourse_subscriptions.user.subscriptions.operations.destroy.confirm"
    }}
    @closeModal={{@closeModal}}
  >
    <:body>
      <Input @type="checkbox" @checked={{refund}} />
      {{i18n "discourse_subscriptions.admin.ask_refund"}}
    </:body>
    <:footer>
      {{#if @model.subscription.loading}}
        <LoadingSpinner />
      {{else}}
        <DButton
          @label="yes_value"
          @action={{route-action
            "cancelSubscription"
            (hash subscription=@model.subscription refund=refund)
          }}
          @icon="times"
          class="btn-danger"
        />
        <DButton @label="no_value" @action={{route-action "closeModal"}} />
      {{/if}}
    </:footer>
  </DModal>

  <div class="modal-footer">
  </div>
</template>;

export default AdminCancelSubscriptions;
