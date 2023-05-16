class AddStandardTravelTimeToRoute < ActiveRecord::Migration[7.0]
  def change
    change_table :routes do |t|
      t.interval :standard_travel_time, null: false, default: 1.minute
    end
  end
end
