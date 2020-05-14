# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :discourse_subscriptions_subscriptions do |t|
      t.integer :customer_id
      t.string :external_id

      t.timestamps
    end
  end
end
