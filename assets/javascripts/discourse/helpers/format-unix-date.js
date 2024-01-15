import { autoUpdatingRelativeAge } from "discourse/lib/formatter";
import { htmlSafe } from "@ember/template";

export default function formatUnixDate(timestamp) {
  if (timestamp) {
    const date = new Date(moment.unix(timestamp).format());

    return new htmlSafe(
      autoUpdatingRelativeAge(date, {
        format: "medium",
        title: true,
        leaveAgo: true,
      })
    );
  }
}
