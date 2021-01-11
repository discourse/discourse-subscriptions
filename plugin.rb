# frozen_string_literal: true

# name: discourse-subscriptions
# about: Integrates Stripe into Discourse to allow visitors to subscribe
# version: 2.8.1
# url: https://github.com/discourse/discourse-subscriptions
# authors: Rimian Perkins, Justin DiRose

enabled_site_setting :discourse_subscriptions_enabled

gem 'stripe', '5.29.0'

register_asset "stylesheets/common/main.scss"
register_asset "stylesheets/common/layout.scss"
register_asset "stylesheets/common/subscribe.scss"
register_asset "stylesheets/mobile/main.scss"
register_svg_icon "far-credit-card" if respond_to?(:register_svg_icon)

register_html_builder('server:before-head-close') do
  "<script src='https://js.stripe.com/v3/'></script>"
end

extend_content_security_policy(
  script_src: ['https://js.stripe.com/v3/', 'https://hooks.stripe.com']
)

add_admin_route 'discourse_subscriptions.admin_navigation', 'discourse-subscriptions.products'

Discourse::Application.routes.append do
  get '/admin/plugins/discourse-subscriptions' => 'admin/plugins#index', constraints: AdminConstraint.new
  get '/admin/plugins/discourse-subscriptions/products' => 'admin/plugins#index', constraints: AdminConstraint.new
  get '/admin/plugins/discourse-subscriptions/products/:product_id' => 'admin/plugins#index', constraints: AdminConstraint.new
  get '/admin/plugins/discourse-subscriptions/products/:product_id/plans' => 'admin/plugins#index', constraints: AdminConstraint.new
  get '/admin/plugins/discourse-subscriptions/products/:product_id/plans/:plan_id' => 'admin/plugins#index', constraints: AdminConstraint.new
  get '/admin/plugins/discourse-subscriptions/subscriptions' => 'admin/plugins#index', constraints: AdminConstraint.new
  get '/admin/plugins/discourse-subscriptions/plans' => 'admin/plugins#index', constraints: AdminConstraint.new
  get '/admin/plugins/discourse-subscriptions/plans/:plan_id' => 'admin/plugins#index', constraints: AdminConstraint.new
  get '/admin/plugins/discourse-subscriptions/coupons' => 'admin/plugins#index', constraints: AdminConstraint.new
  get 'u/:username/billing' => 'users#show', constraints: { username: USERNAME_ROUTE_FORMAT }
  get 'u/:username/billing/:id' => 'users#show', constraints: { username: USERNAME_ROUTE_FORMAT }
end

load File.expand_path('lib/discourse_subscriptions/engine.rb', __dir__)
load File.expand_path('app/controllers/concerns/stripe.rb', __dir__)
load File.expand_path('app/controllers/concerns/group.rb', __dir__)

after_initialize do
  ::Stripe.api_version = "2020-08-27"

  ::Stripe.set_app_info(
    'Discourse Subscriptions',
    version: '2.8.1',
    url: 'https://github.com/discourse/discourse-subscriptions'
  )

  Discourse::Application.routes.append do
    mount ::DiscourseSubscriptions::Engine, at: 's'
  end
end
