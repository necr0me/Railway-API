class CreateRoutes < ActiveRecord::Migration[7.0]
  def change
    create_table :routes, &:timestamps
  end
end
