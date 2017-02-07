# name: choice-plugin
# about: Integrating Discourse with Stripe
# version: 0.0.3
# authors: Rimian Perkins

gem 'stripe', '1.58.0'

Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'] ||  Rails.application.config_for(:stripe)['publishable_key'],
  :secret_key      => ENV['STRIPE_SECRET_KEY'] ||  Rails.application.config_for(:stripe)['secret_key']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

module ::Choice
  class Engine < ::Rails::Engine
    engine_name 'choice'
    isolate_namespace Choice
  end
end

Discourse::Application.routes.prepend do
  mount ::Choice::Engine, at: '/choice'
end
