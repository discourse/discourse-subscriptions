

module DiscourseDonations
  class Rewards
    def initialize(user)
      @user = user
    end

    def add_to_group(name)
      group = ::Group.find_by_name(name)
      return false if group.nil?
      group.add(@user)
      group.present?
    end
  end
end
