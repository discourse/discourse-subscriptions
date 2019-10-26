class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :discourse_patrons_customers do |t|
      t.string :customer_id, null: false
      t.references :user, foreign_key: true
      t.timestamps
    end

    add_index :discourse_patrons_customers, :user_id, unique: true
    add_index :discourse_patrons_customers, :customer_id, unique: true
  end
end
