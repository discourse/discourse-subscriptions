# name: Discourse Patrons
# version: 1.0.0

enabled_site_setting :discourse_patrons_enabled

after_initialize do
  load File.expand_path('../config/routes.rb', __FILE__)
  load File.expand_path('../app/controllers/patrons_controller.rb', __FILE__)
end
