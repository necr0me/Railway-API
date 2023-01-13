class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.string :name, null: false
      t.string :surname, null: false
      t.string :patronymic, null: false
      t.string :phone_number, null: false
      t.string :passport_code, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :profiles, :phone_number, unique: true
    add_index :profiles, :passport_code, unique: true
  end
end
