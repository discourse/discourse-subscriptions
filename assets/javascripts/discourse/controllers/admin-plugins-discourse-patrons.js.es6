export default Ember.Controller.extend({
  queryParams: ["order", "ascending"],
  order: null,
  ascending: true,

  actions: {
    loadMore() {},

    orderPayments(order) {
      if (order === this.get("order")) {
        this.toggleProperty("ascending");
      }

      this.set("order", order);
    }
  }
});
