
module Jobs
  class DonationUser < ::Jobs::Base
    def execute(args)
      user = User.create!(args.slice(:username, :password, :name, :email))
      return unless user.persisted?
      Jobs.enqueue(
        :critical_user_email,
        type: :signup, user_id: user.id, email_token: user.email_tokens.first.token
      )
      rewards = DiscourseDonations::Rewards.new(user)
      args[:rewards].to_a.each do |reward|
        rewards.grant_badge(reward[:name]) if reward[:type] == 'badge'
        rewards.add_to_group(reward[:name]) if reward[:type] == 'group'
      end
    end
  end
end
