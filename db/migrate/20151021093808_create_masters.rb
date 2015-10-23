class CreateMasters < ActiveRecord::Migration
  def change
    create_table :masters do |t|

      t.timestamps null: false
    end
  end
end
