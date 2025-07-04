# frozen_string_literal: true

module DiscourseSubscriptions
  module Group
    extend ActiveSupport::Concern

    def plan_group(plan)
      # This safely gets the group name and won't crash if it's missing.
      group_name = plan.dig(:metadata, :group_name)
      ::Group.find_by_name(group_name) if group_name.present?
    end
  end
end
