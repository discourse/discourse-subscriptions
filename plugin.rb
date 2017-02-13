# name: choice-plugin
# about: Integrating Discourse with Stripe
# version: 1.0.1
# authors: Rimian Perkins
# url: https://github.com/choiceaustralia/choice-discourse

gem 'stripe', '1.58.0'

load File.expand_path('../lib/choice-discourse/engine.rb', __FILE__)

Discourse::Application.routes.prepend do
  mount ::Choice::Engine, at: '/'
end
