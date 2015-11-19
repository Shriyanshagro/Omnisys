class AddLastToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :last, :date
  end
end
