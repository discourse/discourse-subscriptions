import { registerUnbound } from "discourse-common/lib/helpers";
import User from "discourse/models/user";

export default registerUnbound("user-viewing-self", function(model) {
  if (User.current()) {
    return (
      User.current().username.toLowerCase() === model.username.toLowerCase()
    );
  }

  return false;
});
