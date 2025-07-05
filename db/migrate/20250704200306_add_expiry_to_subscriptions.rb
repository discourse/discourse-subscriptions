# frozen_string_literal: true

class AddExpiryToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :discourse_subscriptions_subscriptions, :duration, :integer
    add_column :discourse_subscriptions_subscriptions, :expires_at, :datetime
  end
end
