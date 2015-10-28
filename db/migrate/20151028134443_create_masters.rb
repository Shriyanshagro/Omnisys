class CreateMasters < ActiveRecord::Migration
  def change
    create_table :masters do |t|
      t.text :item_name
      t.text :uom
      t.integer :units
      t.integer :level
      t.integer :conversion
      t.float :mrp

      t.timestamps null: false
    end
  end
end
