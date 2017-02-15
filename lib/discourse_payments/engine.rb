module ::DiscoursePayments
  class Engine < ::Rails::Engine
    engine_name 'discourse-payments'
    isolate_namespace DiscoursePayments
  end
end
