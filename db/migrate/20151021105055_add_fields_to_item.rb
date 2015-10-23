class AddFieldsToItem < ActiveRecord::Migration
  def change
    add_column :items, :item_name, :text
    add_column :items, :quantity, :integer
    add_column :items, :mrp, :float
  end
end
