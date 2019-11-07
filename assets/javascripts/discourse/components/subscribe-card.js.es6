export default Ember.Component.extend({
  didInsertElement() {
    this._super(...arguments);
    this.cardElement.mount("#card-element");
  },
  didDestroyElement() {}
});
