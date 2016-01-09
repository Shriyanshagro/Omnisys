class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :item_name
      t.integer :sold
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
