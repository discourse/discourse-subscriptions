# frozen_string_literal: true

# name: discourse-subscriptions
# about: Integrates Stripe into Discourse to allow visitors to subscribe
# version: 2.8.1
# url: https://github.com/6doworld/discourse-subscriptions
# authors: Rimian Perkins, Justin DiRose
# transpile_js: true

enabled_site_setting :discourse_subscriptions_enabled

gem "stripe", "5.29.0"

register_asset "stylesheets/common/main.scss"
register_asset "stylesheets/common/layout.scss"
register_asset "stylesheets/common/subscribe.scss"
register_asset "stylesheets/common/campaign.scss"
register_asset "stylesheets/mobile/main.scss"
register_svg_icon "far-credit-card" if respond_to?(:register_svg_icon)

register_html_builder("server:before-head-close") do
  "<script src='https://js.stripe.com/v3/'></script>"
end

extend_content_security_policy(script_src: %w[https://js.stripe.com/v3/ https://hooks.stripe.com])

add_admin_route "discourse_subscriptions.admin_navigation", "discourse-subscriptions.products"

Discourse::Application.routes.append do
  get "/admin/plugins/discourse-subscriptions" => "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-subscriptions/products" => "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-subscriptions/products/:product_id" => "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-subscriptions/products/:product_id/plans" => "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-subscriptions/products/:product_id/plans/:plan_id" =>
        "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-subscriptions/subscriptions" => "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-subscriptions/plans" => "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-subscriptions/plans/:plan_id" => "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-subscriptions/coupons" => "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "u/:username/billing" => "users#show", :constraints => { username: USERNAME_ROUTE_FORMAT }
  get "u/:username/billing/:id" => "users#show", :constraints => { username: USERNAME_ROUTE_FORMAT }
  get "u/:username/billing/subscriptions/card/:subscription_id" => "users#show",
      :constraints => {
        username: USERNAME_ROUTE_FORMAT,
      }

  # we want to serve this files from exact url for apple pay
  match "/.well-known/apple-developer-merchantid-domain-association",
        to: proc {|env| [200, {}, [File.open(Rails.root.join('public', 'plugins', 'discourse-subscriptions', 'apple-developer-merchantid-domain-association')).read]] },
        via: :get
end

load File.expand_path("lib/discourse_subscriptions/engine.rb", __dir__)
load File.expand_path("app/controllers/concerns/stripe.rb", __dir__)
load File.expand_path("app/controllers/concerns/group.rb", __dir__)

after_initialize do
  ::Stripe.api_version = "2020-08-27"

  ::Stripe.set_app_info(
    "Discourse Subscriptions",
    version: "2.8.1",
    url: "https://github.com/discourse/discourse-subscriptions",
  )

  Discourse::Application.routes.append { mount ::DiscourseSubscriptions::Engine, at: "s" }

  add_to_serializer(:site, :show_campaign_banner) do
    begin
      enabled = SiteSetting.discourse_subscriptions_enabled
      campaign_enabled = SiteSetting.discourse_subscriptions_campaign_enabled
      goal_met = Discourse.redis.get("subscriptions_goal_met_date")

      enabled && campaign_enabled && (!goal_met || 7.days.ago <= Date.parse(goal_met))
    rescue StandardError
      false
    end
  end
end
