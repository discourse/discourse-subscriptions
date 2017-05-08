
module Jobs
  class DonationUser < ::Jobs::Base
    def execute(args)
      user = User.create!(args)
      rewards = DiscourseDonations::Rewards.new(user)
      args[:rewards].to_a.each do |reward|
        rewards.grant_badge(reward[:name]) if reward[:type] == 'badge'
        rewards.add_to_group(reward[:name]) if reward[:type] == 'group'
      end
    end
  end
end
