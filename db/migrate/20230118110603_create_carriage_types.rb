class CreateCarriageTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :carriage_types do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.integer :capacity, null: false

      t.timestamps
    end
  end
end
