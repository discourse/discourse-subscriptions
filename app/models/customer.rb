# frozen_string_literal: true

module DiscoursePatrons
  class Customer < ActiveRecord::Base
    scope :find_user, ->(user) { find_by_user_id(user.id) }

    class << self
      table_name = "discourse_subscriptions_customers"

      def create_customer(user, customer)
        create(customer_id: customer[:id], user_id: user.id)
      end
    end
  end
end
