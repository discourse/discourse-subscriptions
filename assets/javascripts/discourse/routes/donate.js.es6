import DiscourseRoute from "discourse/routes/discourse";
import { popupAjaxError } from 'discourse/lib/ajax-error';
import { ajax } from 'discourse/lib/ajax';

export default DiscourseRoute.extend({
  setupController(controller) {
    controller.set('loadingDonations', true);

    ajax('/donate/charges').then((result) => {
      if (result && (result.charges || result.subscriptions)) {
        controller.setProperties({
          charges: result.charges,
          subscriptions: result.subscriptions
        });
      }
    }).catch(popupAjaxError).finally(() => {
      controller.set('loadingDonations', false);
    })
  }
});
