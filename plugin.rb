# frozen_string_literal: true

# name: discourse-patrons
# about: Integrates Stripe into Discourse to allow visitors to make payments and Subscribe
# version: 1.2.3
# url: https://github.com/rimian/discourse-patrons
# authors: Rimian Perkins

enabled_site_setting :discourse_patrons_enabled

gem 'stripe', '5.6.0'

register_asset "stylesheets/common/discourse-patrons.scss"
register_asset "stylesheets/mobile/discourse-patrons.scss"

register_html_builder('server:before-head-close') do
  "<script src='https://js.stripe.com/v3/'></script>"
end

extend_content_security_policy(
  script_src: ['https://js.stripe.com/v3/']
)

add_admin_route 'discourse_patrons.title', 'discourse-patrons.dashboard'

Discourse::Application.routes.append do
  get '/admin/plugins/discourse-patrons/dashboard' => 'admin/plugins#index'
  get '/admin/plugins/discourse-patrons/subscriptions' => 'admin/plugins#index'
  get '/admin/plugins/discourse-patrons/plans' => 'admin/plugins#index'
  get '/admin/plugins/discourse-patrons/plans/:plan_id' => 'admin/plugins#index'
end

after_initialize do
  ::Stripe.api_version = "2019-08-14"
  ::Stripe.set_app_info('Discourse Patrons', version: '1.2.3', url: 'https://github.com/rimian/discourse-patrons')

  [
    "../lib/discourse_patrons/engine",
    "../config/routes",
    "../app/controllers/concerns/stripe",
    "../app/controllers/admin_controller",
    "../app/controllers/admin/plans_controller",
    "../app/controllers/admin/subscriptions_controller",
    "../app/controllers/patrons_controller",
    "../app/models/payment",
    "../app/serializers/payment_serializer",
  ].each { |path| require File.expand_path(path, __FILE__) }

  Discourse::Application.routes.append do
    mount ::DiscoursePatrons::Engine, at: 'patrons'
  end
end
