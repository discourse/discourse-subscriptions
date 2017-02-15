# name: discourse-payments
# about: Integrating Discourse with Stripe
# version: 1.0.1
# url: https://github.com/choiceaustralia/discourse-payments

gem 'stripe', '1.58.0'

load File.expand_path('../lib/discourse-payments/engine.rb', __FILE__)

Discourse::Application.routes.prepend do
  mount ::Choice::Engine, at: '/'
end
