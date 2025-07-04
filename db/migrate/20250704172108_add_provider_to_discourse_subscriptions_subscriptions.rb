# frozen_string_literal: true

class AddProviderToDiscourseSubscriptionsSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :discourse_subscriptions_subscriptions, :provider, :string
  end
end
