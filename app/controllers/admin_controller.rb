# frozen_string_literal: true

module DiscoursePatrons
  class AdminController < ::Admin::AdminController
    def index
      head 200
    end
  end
end
