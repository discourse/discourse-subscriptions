# frozen_string_literal: true

module DiscourseSubscriptions
  class Subscription < ActiveRecord::Base
    belongs_to :customer
  end
end
