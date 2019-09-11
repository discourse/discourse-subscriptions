# frozen_string_literal: true

# name: discourse-patrons
# about: Integrates Stripe into Discourse to allow visitors to make payments
# version: 1.0.0
# url: https://github.com/rimian/discourse-patrons
# authors: Rimian Perkins

enabled_site_setting :discourse_patrons_enabled

load File.expand_path('../lib/discourse_patrons/engine.rb', __FILE__)

Discourse::Application.routes.append do
  mount ::DiscoursePatrons::Engine, at: '/patrons'
end
