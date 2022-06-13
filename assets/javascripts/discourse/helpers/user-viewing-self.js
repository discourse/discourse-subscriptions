import { helperContext, registerUnbound } from "discourse-common/lib/helpers";

export default registerUnbound("user-viewing-self", function (model) {
  let currentUser = helperContext().currentUser;
  if (currentUser) {
    return (
      currentUser.admin ||
      currentUser.username?.toLowerCase() === model.username?.toLowerCase()
    );
  }

  return false;
});
