class AddFirstToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :first, :date
  end
end
