class RemoveValueFromReport < ActiveRecord::Migration
  def change
    remove_column :reports, :value, :integer
  end
end
