import componentTest from 'helpers/component-test';

moduleForComponent('stripe-card', { integration: true });

componentTest('stripe card', {
  template: `{{stripe-card}}`,

  setup() {
    // var spy = this.spy();
    sandbox.spy();
  },

  test(assert) {
    assert.ok(true);
  }
});


// componentTest("should call all subscribers when exceptions", function () {
//     var myAPI = { method: function () {} };
//
//     var spy = this.spy();
//     var mock = this.mock(myAPI);
//     mock.expects("method").once().throws();
//
//     PubSub.subscribe("message", myAPI.method);
//     PubSub.subscribe("message", spy);
//     PubSub.publishSync("message", undefined);
//
//     mock.verify();
//     ok(spy.calledOnce);
// });
