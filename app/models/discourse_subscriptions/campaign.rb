# frozen_string_literal: true

module DiscourseSubscriptions
  class Campaign
    def initialize
      @subscribers = 0
      @amount = 0
      # initialize Stripe here
    end

    def self.subscribers
      @subscribers
    end

    def self.amount_raised
      @amount
    end

    def refresh_data
    end

    private
  end
end
