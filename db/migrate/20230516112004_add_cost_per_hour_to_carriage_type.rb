class AddCostPerHourToCarriageType < ActiveRecord::Migration[7.0]
  def change
    change_table :carriage_types do |t|
      t.float :cost_per_hour, null: false, default: 1.0
    end
  end
end
