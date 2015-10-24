class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.text :customer
      t.text :item_name
      t.integer :quantity
      t.text :unit_of_measure
      t.text :batch_number
      t.date :expiry_date
      t.date :date_of_purchase
      t.float :total_price

      t.timestamps null: false
    end
  end
end
