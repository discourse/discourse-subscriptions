import User from "discourse/models/user";

export default function userViewingSelf(model) {
  if (User.current()) {
    return (
      User.current().username.toLowerCase() === model.username.toLowerCase()
    );
  }

  return false;
}
