# name: choice-plugin
# about: Integrating CHOICE with Discourse
# version: 0.0.2
# authors: Rimian Perkins

gem 'stripe'

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
