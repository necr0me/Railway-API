class CreateTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :tickets do |t|
      t.float :price
      t.integer :user_id, null: false
      t.integer :seat_id, null: false
      t.integer :arrival_station_id, null: false
      t.integer :departure_station_id, null: false

      t.timestamps
    end
    add_foreign_key :tickets, :users
    add_foreign_key :tickets, :seats
    add_foreign_key :tickets, :stations, column: :arrival_station_id, primary_key: :id
    add_foreign_key :tickets, :stations, column: :departure_station_id, primary_key: :id
  end
end
