
export default Ember.Controller.extend({
  queryParams: ["order", "descending"],
  order: null,
  descending: true,

  actions: {
    loadMore() {},

    orderPayments(order) {
      if (order === this.get("order")) {
        this.toggleProperty("descending");
      }

      this.set("order", order);
    }
  }
});
