class CreateStations < ActiveRecord::Migration[7.0]
  def change
    create_table :stations do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :stations, :name, unique: true
  end
end
