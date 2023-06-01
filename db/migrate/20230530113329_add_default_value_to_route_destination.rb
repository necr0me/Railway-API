class AddDefaultValueToRouteDestination < ActiveRecord::Migration[7.0]
  def change
    change_column_default(:routes, :destination, from: nil, to: "")
  end
end
