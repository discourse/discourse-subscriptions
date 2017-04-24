

module DiscourseDonations
  class Rewards
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def add_to_group(name)
      grp = ::Group.find_by_name(name)
      return if grp.nil?
      log_group_add(grp)
      grp.add(user)
    end

    def grant_badge(name)
      badge = ::Badge.find_by_name(name)
      return if badge.nil?
      BadgeGranter.grant(badge, user)
    end

    def log_group_add(grp)
      system_user = User.find(-1)
      GroupActionLogger.new(system_user, grp).log_add_user_to_group(user)
    end
  end
end
