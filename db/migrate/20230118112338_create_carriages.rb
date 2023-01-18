class CreateCarriages < ActiveRecord::Migration[7.0]
  def change
    create_table :carriages do |t|
      t.string :name, null: false
      t.references :carriage_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
