# name: discourse-donations
# about: Integrating Discourse with Stripe for donations
# version: 1.6.1
# url: https://github.com/choiceaustralia/discourse-donations
# authors: Rimian Perkins

gem 'stripe', '2.0.1'

load File.expand_path('../lib/discourse_donations/engine.rb', __FILE__)
load File.expand_path('../config/stripe.rb', __FILE__)

after_initialize do
  header_script = '<script src="https://js.stripe.com/v3/"></script>'

  discourse_payments_customization = SiteCustomization.find_or_create_by({
    name: 'Discourse Donations Header',
    header: header_script,
    mobile_header: header_script,
    enabled: true,
    user_id: -1
  })

  # Delete the old header (1.5.0)
  SiteCustomization.where(name: 'Discourse Payments Header').delete_all
  SiteCustomization.where(name: discourse_payments_customization.name).where.not(id: discourse_payments_customization.id).delete_all
end

Discourse::Application.routes.prepend do
  mount ::DiscourseDonations::Engine, at: '/'
end
