
module Jobs
  class GrantBadge < ::Jobs::Scheduled
    every 5.minutes

    def execute(_args)
      puts "===================== Running badge grant ========================"
      puts user_queue
      user_queue.each do |email|
        user = User.find_by_email(email)
        next if user.nil?
        puts "Granted user #{user.email} with badge: #{badge_name}"
        DiscourseDonations::Rewards.new(user).grant_badge(badge_name)
      end
      user_queue_reset
    end

    private

    def user_queue
      PluginStore.get('discourse-donations', 'badge:grant') || []
    end

    def user_queue_reset
      PluginStore.set('discourse-donations', 'badge:grant', [])
    end

    def badge_name
      SiteSetting.discourse_donations_reward_badge_name
    end
  end
end
