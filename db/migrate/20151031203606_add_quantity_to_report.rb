class AddQuantityToReport < ActiveRecord::Migration
  def change
    add_column :reports, :quantity, :integer
  end
end
