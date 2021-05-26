# frozen_string_literal: true

module DiscourseSubscriptions
  class AdminController < ::Admin::AdminController
    def index
      head 200
    end

    def refresh_campaign
      Jobs.enqueue(:manually_update_campaign_data)
      render json: success_json
    end
  end
end
