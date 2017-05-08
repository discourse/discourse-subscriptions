
module Jobs
  class DonationUser < ::Jobs::Base
    def execute(args)
      user = User.create!(args)
      if args[:rewards].present?
        DiscourseDonations::Rewards.new(user).grant_badge(args[:rewards][:name])
      end
    end
  end
end
