# name: discourse-donations
# about: Integrating Discourse with Stripe for donations
# version: 1.6.4
# url: https://github.com/choiceaustralia/discourse-donations
# authors: Rimian Perkins

gem 'stripe', '2.0.1'

load File.expand_path('../lib/discourse_donations/engine.rb', __FILE__)
load File.expand_path('../config/stripe.rb', __FILE__)

enabled_site_setting :discourse_donations_enabled

after_initialize do
  header_script = '<script src="https://js.stripe.com/v3/"></script>'

  discourse_donations_customization = SiteCustomization.find_or_create_by({
    name: 'Discourse Donations Header',
    header: header_script,
    mobile_header: header_script,
    enabled: true,
    user_id: -1
  })

  SiteCustomization.where(name: discourse_donations_customization.name).where.not(id: discourse_donations_customization.id).delete_all
end

Discourse::Application.routes.prepend do
  mount ::DiscourseDonations::Engine, at: '/'
end
