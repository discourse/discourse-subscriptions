# frozen_string_literal: true

module DiscoursePatrons
  class PatronsController < ApplicationController
    def index
      result = {}
      render json: result
    end

    def create
      render json: {}
    end
  end
end
