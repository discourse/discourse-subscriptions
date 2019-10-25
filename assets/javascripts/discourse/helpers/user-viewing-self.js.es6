import { registerUnbound } from 'discourse-common/lib/helpers';

export default registerUnbound('user-viewing-self', function(model) {
  if (Discourse.User.current()){
    return Discourse.User.current().username.toLowerCase() === model.username.toLowerCase();
  }

  return false;
});
