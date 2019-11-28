class RemoveCustomerIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :discourse_patrons_customers, :customer_id
  end
end
