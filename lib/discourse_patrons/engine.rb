# frozen_string_literal: true

module ::DiscoursePatrons
  class Engine < ::Rails::Engine
    engine_name 'discourse-patrons'
    isolate_namespace DiscoursePatrons
  end
end
