class CreateSeats < ActiveRecord::Migration[7.0]
  def change
    create_table :seats do |t|
      t.integer :number
      t.boolean :is_taken, null: false, default: false
      t.references :carriage, null: false, foreign_key: true

      t.timestamps
    end
  end
end
