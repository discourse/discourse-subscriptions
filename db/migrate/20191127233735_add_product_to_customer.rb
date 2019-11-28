class AddProductToCustomer < ActiveRecord::Migration[6.0]
  def change
    add_column :discourse_patrons_customers, :product_id, :string
  end
end
