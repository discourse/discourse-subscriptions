
module Jobs
  class AwardGroup < ::Jobs::Onceoff
    def execute_onceoff(args)
      puts '====================== The Job was executed ==========================='
      user = User.find_by_email(args[:email])
      if user.present?
        DiscourseDonations::Rewards.new(user).add_to_group(args[:group_name])
      end
    end
  end
end
