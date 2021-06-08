export default {
  shouldRender(args, component) {
    const { siteSettings } = component;
    const mobileView = component.site.mobileView;
    const bannerLocation =
      siteSettings.discourse_subscriptions_campaign_banner_location;

    return (
      bannerLocation === "Top" || (bannerLocation === "Sidebar" && mobileView)
    );
  },
};
