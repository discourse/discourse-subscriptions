# Discourse forces the namespace at top level :(

module Jobs
  class AwardGroup
    def perform(args)
      puts '======================The Job was performed==========================='
    end
  end
end
