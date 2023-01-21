class CreateTrains < ActiveRecord::Migration[7.0]
  def change
    create_table :trains do |t|
      t.references :route, foreign_key: true

      t.timestamps
    end
  end
end
