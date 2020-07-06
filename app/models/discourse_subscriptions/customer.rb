# frozen_string_literal: true

module DiscourseSubscriptions
  class Customer < ActiveRecord::Base
    self.table_name = "discourse_subscriptions_customers"

    scope :find_user, ->(user) { find_by_user_id(user.id) }

    has_many :subscriptions

    def self.create_customer(user, customer)
      create(customer_id: customer[:id], user_id: user.id)
    end
  end
end
