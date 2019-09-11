# frozen_string_literal: true

module ::DiscoursePatrons
  PLUGIN_NAME = "discourse-patrons"

  class Engine < ::Rails::Engine
    engine_name DiscoursePatrons::PLUGIN_NAME
    isolate_namespace DiscoursePatrons
  end
end
