# name: discourse-payments
# about: Integrating Discourse with Stripe
# version: 1.1.0
# url: https://github.com/choiceaustralia/discourse-payments

gem 'stripe', '1.58.0'

load File.expand_path('../lib/discourse_payments/engine.rb', __FILE__)

Discourse::Application.routes.prepend do
  mount ::DiscoursePayments::Engine, at: '/'
end
