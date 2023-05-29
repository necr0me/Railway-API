class ChangeArrivalAndDepartureTicketsColumns < ActiveRecord::Migration[7.0]
  def up
    change_table :tickets, bulk: true do |t|
      t.remove_foreign_key column: :arrival_station_id
      t.remove_foreign_key column: :departure_station_id
      t.remove :arrival_station_id, :departure_station_id

      t.integer :arrival_stop_id, :departure_stop_id, null: false
      t.foreign_key :train_stops, column: :arrival_stop_id, primary_key: :id
      t.foreign_key :train_stops, column: :departure_stop_id, primary_key: :id
    end
  end

  def down
    change_table :tickets, bulk: true do |t|
      t.remove_foreign_key column: :arrival_stop_id
      t.remove_foreign_key column: :departure_stop_id
      t.remove :arrival_stop_id, :departure_stop_id

      t.integer :arrival_station_id, :departure_station_id, null: false
      t.foreign_key :stations, column: :arrival_station_id, primary_key: :id
      t.foreign_key :stations, column: :departure_station_id, primary_key: :id
    end
  end
end
