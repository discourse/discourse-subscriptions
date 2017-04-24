

module DiscourseDonations
  class Rewards
    def initialize(user)
      @user = user
    end

    def add_to_group(name)
      grp = ::Group.find_by_name(name)
      return if grp.nil?
      grp.add(@user)
    end

    def grant_badge(name)
      badge = ::Badge.find_by_name(name)
      return if badge.nil?
      BadgeGranter.grant(badge, @user)
    end
  end
end
