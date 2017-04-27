
module Jobs
  class GrantBadge < ::Jobs::Scheduled
    every 5.minutes

    def execute(_args)
      puts '====================== The Grant Badge Job was executed ==========================='
    end
  end
end
