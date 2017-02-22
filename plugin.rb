# name: discourse-payments
# about: Integrating Discourse with Stripe
# version: 1.3.0
# url: https://github.com/choiceaustralia/discourse-payments
# authors: Rimian Perkins

gem 'stripe', '2.0.1'

load File.expand_path('../lib/discourse_payments/engine.rb', __FILE__)
load File.expand_path('../config/stripe.rb', __FILE__)

after_initialize do
  header_script = '<script src="https://js.stripe.com/v3/"></script>'

  discourse_payments_customization = SiteCustomization.find_or_create_by({
    name: 'Discourse Payments Header',
    header: header_script,
    mobile_header: header_script,
    enabled: true,
    user_id: -1
  })

  SiteCustomization.where(name: discourse_payments_customization.name).where.not(id: discourse_payments_customization.id).delete_all
end

Discourse::Application.routes.prepend do
  mount ::DiscoursePayments::Engine, at: '/'
end
