# name: discourse-donations
# about: Integrating Discourse with Stripe for donations
# version: 1.11.1
# url: https://github.com/choiceaustralia/discourse-donations
# authors: Rimian Perkins

gem 'stripe', '2.8.0'

load File.expand_path('../lib/discourse_donations/engine.rb', __FILE__)

enabled_site_setting :discourse_donations_enabled

after_initialize do
  load File.expand_path('../app/jobs/jobs.rb', __FILE__)
end

Discourse::Application.routes.prepend do
  mount ::DiscourseDonations::Engine, at: '/'
end
