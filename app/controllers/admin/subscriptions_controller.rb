# frozen_string_literal: true

module DiscoursePatrons
  class SubscriptionsController < ::Admin::AdminController
    def index
      head 200
    end
  end
end
