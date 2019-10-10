export function stubStripe() {
  window.Stripe = () => {
    return {
      createPaymentMethod() {
        return new Ember.RSVP.Promise(resolve => {
          resolve({});
        });
      },
      elements() {
        return {
          create() {
            return {
              on() {},
              card() {},
              mount() {}
            };
          }
        };
      }
    };
  };
}
