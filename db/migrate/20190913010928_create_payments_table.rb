# frozen_string_literal: true

class CreatePaymentsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.timestamps
    end

    # add_index :payments, [:payment_intent_id], unique: true
  end
end
