require_relative '../../app/jobs/award_group'

module ::DiscourseDonations
  class Engine < ::Rails::Engine
    engine_name 'discourse-donations'
    isolate_namespace DiscourseDonations
  end
end
