# Discourse forces the namespace at top level :(

module Jobs
  class AwardGroup
    def perform(args)
      puts '======================The Job was performed==========================='
    end

    def self.perform_in(arg, opts)
      puts '======================The Job was enqueued==========================='
    end

    def execute(args)
      user = User.find_by_email(args[:email])
      if user.present?
        DiscourseDonations::Rewards.new(user).add_to_group(args[:group_name])
      end
    end
  end
end
