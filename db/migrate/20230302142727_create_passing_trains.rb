class CreatePassingTrains < ActiveRecord::Migration[7.0]
  def change
    create_table :passing_trains do |t|
      t.datetime :departure_time, null: false
      t.datetime :arrival_time, null: false
      t.integer :way_number, null: false

      t.references :train, :station

      t.timestamps
    end
    add_foreign_key :passing_trains, :trains, column: :train_id, primary_key: :id
    add_foreign_key :passing_trains, :stations, column: :station_id, primary_key: :id
  end
end
