import { registerUnbound } from "discourse-common/lib/helpers";
import { autoUpdatingRelativeAge } from "discourse/lib/formatter";

registerUnbound("format-unix-date", function(timestamp) {
  if (timestamp) {
    const date = new Date(moment.unix(timestamp).format());

    return new Handlebars.SafeString(
      autoUpdatingRelativeAge(date, {
        format: "medium",
        title: true,
        leaveAgo: true
      })
    );
  }
});
