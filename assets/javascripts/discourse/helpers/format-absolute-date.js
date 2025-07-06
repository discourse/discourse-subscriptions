import { helper } from "@ember/component/helper";
import { htmlSafe } from "@ember/template";

export default helper(function formatAbsoluteDate([timestamp]) {
  if (timestamp) {
    // LL format gives a localized, human-readable date like "July 7, 2025"
    const formattedDate = moment.unix(timestamp).format("LL");
    return htmlSafe(formattedDate);
  }
  return "N/A"; // Return Not Applicable if there's no date
});
