# frozen_string_literal: true

module DiscourseSubscriptions
  class HooksController < ::ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]

    def create
      head 200
    end
  end
end
