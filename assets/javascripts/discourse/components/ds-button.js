import Button from "discourse/components/d-button";

export default Button.extend({
  seleted: false,

  init() {
    this._super(...arguments);
    this.classNameBindings = this.classNameBindings.concat(
      "selected:btn-primary"
    );
  },
});
