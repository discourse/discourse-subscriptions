export default Ember.Controller.extend({
  queryParams: ["order"],
  order: null,

  actions: {
    loadMore() {},

    orderPayments(order) {
      this.set("order", order);
    }
  }
});
