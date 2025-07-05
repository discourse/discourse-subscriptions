# frozen_string_literal: true

module DiscourseSubscriptions
  module Group
    extend ActiveSupport::Concern

    def plan_group(plan)
      # THIS IS THE FIX: We use object accessors (.metadata.group_name)
      # and safety checks instead of .dig
      group_name = plan.metadata.group_name if plan&.metadata
      ::Group.find_by(name: group_name) if group_name.present?
    end
  end
end
