class AddValueToReport < ActiveRecord::Migration
  def change
    add_column :reports, :value, :float
  end
end
