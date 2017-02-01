# name: choice-plugin
# about: Integrating Discourse with Stripe
# version: 0.0.3
# authors: Rimian Perkins

gem 'stripe', '1.58.0'

Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
  :secret_key      => ENV['STRIPE_SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

module ::Choice
  class Engine < ::Rails::Engine
    engine_name 'choice'
    isolate_namespace Choice
  end
end

after_initialize do
  Discourse::Application.routes.prepend do
    mount ::Choice::Engine, at: '/choice'
  end
end
