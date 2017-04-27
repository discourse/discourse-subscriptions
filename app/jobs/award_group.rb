
module Jobs
  class AwardGroup < ::Jobs::Scheduled
    every 1.minutes

    def execute(_args)
      user_queue.each do |email|
        user = User.find_by_email(email)
        next if user.nil?
        puts "Added user #{user.email} to #{group_name}"
        DiscourseDonations::Rewards.new(user).add_to_group(group_name)
      end
      user_queue_reset
    end

    private

    def user_queue
      PluginStore.get('discourse-donations', 'group:add') || []
    end

    def user_queue_reset
      PluginStore.set('discourse-donations', 'group:add', [])
    end

    def group_name
      SiteSetting.discourse_donations_reward_group_name
    end
  end
end
