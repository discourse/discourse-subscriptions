export default Ember.Controller.extend({
  actions: {
    confirm() {
      this.get("model.confirm")();
      this.send("closeModal");
    },

    cancel() {
      this.send("closeModal");
    }
  }
});
