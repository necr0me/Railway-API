class AddNumOfWaysToStations < ActiveRecord::Migration[7.0]
  def change
    change_table :stations do |t|
      t.integer :number_of_ways, limit: 2, null: false, default: 1
    end
  end
end
