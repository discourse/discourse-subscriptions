

module DiscourseDonations
  class Rewards
    def initialize(user)
      @user = user
    end

    def add_to_group(name)
      group = ::Group.find_by_name(name)
      group.add(@user) if group.present?
    end
  end
end
