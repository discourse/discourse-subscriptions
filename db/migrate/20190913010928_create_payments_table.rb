# frozen_string_literal: true

class CreatePaymentsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.integer :payment_intent_id, null: false
      t.string :receipt_email, null: false
      t.string :url, null: false
      t.integer :amount, null: false
      t.references :user, foreign_key: true
      t.timestamps
    end

    add_index :payments, :payment_intent_id, unique: true
  end
end
