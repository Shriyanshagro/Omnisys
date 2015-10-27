class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.text :item_name
      t.text :unit_of_measure
      t.text :batch_number
      t.integer :quantity
      t.date :expiry_date

      t.timestamps null: false
    end
  end
end
