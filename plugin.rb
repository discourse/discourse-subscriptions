# name: choice-plugin
# about: Integrating Discourse with Stripe
# version: 0.1.0
# authors: Rimian Perkins

gem 'stripe', '1.58.0'

Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'] ||  Rails.application.config_for(:stripe)['publishable_key'],
  :secret_key      => ENV['STRIPE_SECRET_KEY'] ||  Rails.application.config_for(:stripe)['secret_key']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

load File.expand_path('../lib/choice-discourse/engine.rb', __FILE__)

Discourse::Application.routes.prepend do
  mount ::Choice::Engine, at: '/choice'
end
