# frozen_string_literal: true

# name: Discourse Patrons
# about: Integrates Stripe into Discourse to allow visitors to make payments
# version: 1.0.0
# url: https://github.com/rimian/discourse-patrons
# authors: Rimian Perkins

enabled_site_setting :discourse_patrons_enabled

gem 'stripe', '5.1.1'

register_asset "stylesheets/common/discourse-patrons.scss"
register_asset "stylesheets/mobile/discourse-patrons.scss"

register_html_builder('server:before-head-close') do
  "<script src='https://js.stripe.com/v3/'></script>"
end

extend_content_security_policy(
  script_src: ['https://js.stripe.com/v3/']
)

after_initialize do
  ::Stripe.api_version = "2019-08-14"
  ::Stripe.set_app_info('Discourse Patrons', version: '1.0.0', url: 'https://github.com/rimian/discourse-patrons')

  load File.expand_path('../lib/discourse_patrons/engine.rb', __FILE__)
  load File.expand_path('../config/routes.rb', __FILE__)
  load File.expand_path('../app/controllers/patrons_controller.rb', __FILE__)

  Discourse::Application.routes.append do
    mount ::DiscoursePatrons::Engine, at: 'patrons'
  end
end
