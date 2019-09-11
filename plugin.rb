# name: Discourse Patrons
# version: 1.0.0

enabled_site_setting :discourse_patrons_enabled

after_initialize do
  load File.expand_path('../lib/discourse_patrons/engine.rb', __FILE__)
  load File.expand_path('../config/routes.rb', __FILE__)
  load File.expand_path('../app/controllers/patrons_controller.rb', __FILE__)

  Discourse::Application.routes.append do
    mount ::DiscoursePatrons::Engine, at: 'patrons'
  end
end
