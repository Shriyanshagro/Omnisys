class AddFieldsToMaster < ActiveRecord::Migration
  def change
    add_column :masters, :item_name, :text
    add_column :masters, :uom, :text
    add_column :masters, :units, :integer
    add_column :masters, :level, :integer
    add_column :masters, :conversion, :integer
    add_column :masters, :mrp, :float
  end
end
