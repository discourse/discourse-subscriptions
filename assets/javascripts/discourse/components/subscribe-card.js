import Component from "@ember/component";

export default Component.extend({
  didInsertElement() {
    this._super(...arguments);
    this.cardElement.mount("#card-element");
    this.setCardElementStyles();
  },

  setCardElementStyles() {
    const root = document.querySelector(":root");
    const computedStyle = getComputedStyle(root);
    const primaryColor = computedStyle.getPropertyValue("--primary");
    const placeholderColor = computedStyle.getPropertyValue("--primary-medium");
    this.cardElement.update({
      style: {
        base: {
          color: primaryColor,
          "::placeholder": {
            color: placeholderColor,
          },
        },
      },
    });
  },
  didDestroyElement() {},
});
