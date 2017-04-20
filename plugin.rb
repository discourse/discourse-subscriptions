# name: discourse-donations
# about: Integrating Discourse with Stripe for donations
# version: 1.8.0
# url: https://github.com/choiceaustralia/discourse-donations
# authors: Rimian Perkins

gem 'stripe', '2.1.0'

load File.expand_path('../lib/discourse_donations/engine.rb', __FILE__)

enabled_site_setting :discourse_donations_enabled

after_initialize do
  # Must be placed on every page for fraud protection.
  header_script = '<script src="https://js.stripe.com/v3/"></script>'
  discourse_donations_theme = Theme.find_or_create_by(name: 'Discourse Donations Header', hidden: false, user_id: -1)
  discourse_donations_theme.set_field('common', 'head_tag', header_script)
end

Discourse::Application.routes.prepend do
  mount ::DiscourseDonations::Engine, at: '/'
end
