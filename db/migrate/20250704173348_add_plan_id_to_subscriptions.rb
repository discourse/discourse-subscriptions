# frozen_string_literal: true

class AddPlanIdToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :discourse_subscriptions_subscriptions, :plan_id, :string
  end
end
